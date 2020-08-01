/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit

class ModalInputPresentationController: UIPresentationController {
    let configuration: ModalInputPresentationConfiguration

    private var backgroundView: UIView?
    private var headerView: RoundedView?

    var interactiveDismissal: UIPercentDrivenInteractiveTransition?
    var initialTranslation: CGPoint = .zero

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         configuration: ModalInputPresentationConfiguration) {

        self.configuration = configuration

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        if let modalInputView = presentedViewController.view as? ModalInputViewProtocol {
            modalInputView.presenter = self
        }
    }

    private func configureBackgroundView(on view: UIView) {
        if let currentBackgroundView = backgroundView {
            view.insertSubview(currentBackgroundView, at: 0)
        } else {
            let newBackgroundView = UIView(frame: view.bounds)

            newBackgroundView.backgroundColor = UIColor.black
                .withAlphaComponent(configuration.style.shadowOpacity)

            view.insertSubview(newBackgroundView, at: 0)
            backgroundView = newBackgroundView
        }

        backgroundView?.frame = view.bounds
    }

    private func configureHeaderView(on view: UIView, style: ModalInputPresentationHeaderStyle) {
        let width = containerView?.bounds.width ?? view.bounds.width

        if let headerView = headerView {
            view.insertSubview(headerView, at: 0)
        } else {
            let baseView = RoundedView()
            baseView.cornerRadius = style.cornerRadius
            baseView.roundingCorners = [.topLeft, .topRight]
            baseView.fillColor = style.backgroundColor
            baseView.highlightedFillColor = style.backgroundColor
            baseView.shadowOpacity = 0.0

            let indicator = RoundedView()
            indicator.roundingCorners = .allCorners
            indicator.cornerRadius = style.indicatorSize.height / 2.0
            indicator.fillColor = style.indicatorColor
            indicator.highlightedFillColor = style.indicatorColor
            indicator.shadowOpacity = 0.0

            baseView.addSubview(indicator)

            let indicatorX = width / 2.0 - style.indicatorSize.width / 2.0
            indicator.frame = CGRect(origin: CGPoint(x: indicatorX, y: style.indicatorVerticalOffset), size: style.indicatorSize)

            view.insertSubview(baseView, at: 0)

            headerView = baseView
        }

        headerView?.frame = CGRect(x: 0.0,
                                   y: -style.preferredHeight + 0.5,
                                   width: width,
                                   height: style.preferredHeight)
    }

    private func attachCancellationGesture() {
        let cancellationGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(actionDidCancel(gesture:)))
        backgroundView?.addGestureRecognizer(cancellationGesture)
    }

    private func attachPanGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        containerView?.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }

    // MARK: Presentation overridings

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        configureBackgroundView(on: containerView)

        if let headerStyle = configuration.style.headerStyle {
            configureHeaderView(on: presentedViewController.view, style: headerStyle)
        }

        attachCancellationGesture()
        attachPanGesture()

        animateBackgroundAlpha(fromValue: 0.0, toValue: 1.0)
    }

    override func dismissalTransitionWillBegin() {
        animateBackgroundAlpha(fromValue: 1.0, toValue: 0.0)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }

        var layoutFrame = containerView.bounds

        if #available(iOS 11.0, *) {
            layoutFrame = containerView.safeAreaLayoutGuide.layoutFrame
        }

        let preferredSize = presentedViewController.preferredContentSize
        let layoutWidth = preferredSize.width > 0.0 ? preferredSize.width : layoutFrame.width
        let layoutHeight = preferredSize.height > 0.0 ? preferredSize.height : layoutFrame.height

        return CGRect(x: layoutFrame.minX,
                      y: layoutFrame.maxY - layoutHeight,
                      width: layoutWidth,
                      height: layoutHeight)
    }

    // MARK: Animation

    func animateBackgroundAlpha(fromValue: CGFloat, toValue: CGFloat) {
        backgroundView?.alpha = fromValue

        let animationBlock: (UIViewControllerTransitionCoordinatorContext) -> Void = { _ in
            self.backgroundView?.alpha = toValue
        }

        presentingViewController.transitionCoordinator?
            .animate(alongsideTransition: animationBlock, completion: nil)
    }

    func dismiss(animated: Bool) {
        presentingViewController.dismiss(animated: animated, completion: nil)
    }

    // MARK: Action

    @objc func actionDidCancel(gesture: UITapGestureRecognizer) {
        guard let modalInputView = presentedView as? ModalInputViewPresenterDelegate else {
            dismiss(animated: true)
            return
        }

        if modalInputView.presenterShouldHide(self) {
            dismiss(animated: true)
        }
    }

    // MARK: Interactive dismissal

    @objc func didPan(sender: Any?) {
        guard let panGestureRecognizer = sender as? UIPanGestureRecognizer else { return }
        guard let view = panGestureRecognizer.view else { return }

        handlePan(from: panGestureRecognizer, on: view)
    }

    private func handlePan(from panGestureRecognizer: UIPanGestureRecognizer, on view: UIView) {
        let translation = panGestureRecognizer.translation(in: view)
        let velocity = panGestureRecognizer.velocity(in: view)

        switch panGestureRecognizer.state {
        case .began, .changed:

            if let interactiveDismissal = interactiveDismissal {
                let progress = min(1.0, max(0.0, (translation.y - initialTranslation.y) / max(1.0, view.bounds.size.height)))

                interactiveDismissal.update(progress)
            } else {
                interactiveDismissal = UIPercentDrivenInteractiveTransition()
                initialTranslation = translation
                presentedViewController.dismiss(animated: true)
            }
        case .cancelled, .ended:
            if let interactiveDismissal = interactiveDismissal {
                let thresholdReached = interactiveDismissal.percentComplete >= configuration.dismissPercentThreshold
                let shouldDismiss = (thresholdReached && velocity.y >= 0) ||
                    (velocity.y >= configuration.dismissVelocityThreshold && translation.y >= configuration.dismissMinimumOffset)
                stopPullToDismiss(finished: panGestureRecognizer.state != .cancelled && shouldDismiss)
            }
        default:
            break
        }
    }

    private func stopPullToDismiss(finished: Bool) {
        guard let interactiveDismissal = interactiveDismissal else {
            return
        }

        if finished {
            interactiveDismissal.completionSpeed = configuration.dismissFinishSpeedFactor
            interactiveDismissal.finish()
        } else {
            interactiveDismissal.completionSpeed = configuration.dismissCancelSpeedFactor
            interactiveDismissal.cancel()
        }

        self.interactiveDismissal = nil
    }
}

extension ModalInputPresentationController: ModalInputViewPresenterProtocol {
    func hide(view: ModalInputViewProtocol, animated: Bool) {
        guard interactiveDismissal == nil else {
            return
        }

        dismiss(animated: animated)
    }
}

extension ModalInputPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
