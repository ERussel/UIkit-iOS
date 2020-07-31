/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: GPL-3.0
*/

import UIKit
import SoraUI

final class ListViewController: UITableViewController {
    enum ListItemType: Int {
        case roundedButtons
        case gradientButtons
        case pincodeInput
        case textCodeInput
        case loadingView
        case actionTitle
        case segmentedControl
        case details
        case emptyState
        case modalPresentation
        case skeleton
        case modalDraggable
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let listItemType = ListItemType(rawValue: indexPath.row) else {
            return
        }

        switch listItemType {
        case .roundedButtons:
            let controller = RoundedButtonsViewController(nibName: "RoundedButtonsViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .gradientButtons:
            let controller = GradientButtonsViewController(nibName: "GradientButtonsViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .loadingView:
            let controller = LoadingViewController(nibName: "LoadingViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .pincodeInput:
            let controller = PincodeViewController(nibName: "PincodeViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .textCodeInput:
            let controller = TextCodeViewController(nibName: "TextCodeViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .actionTitle:
            let controller = ActionTitleViewController(nibName: "ActionTitleViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .segmentedControl:
            let controller = SegmentedControlViewController(nibName: "SegmentedControlViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .details:
            let controller = DetailsViewController(nibName: "DetailsViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .emptyState:
            let controller = EmptyStateViewController(nibName: "EmptyStateViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .modalPresentation:
            let controller = ModalPresentationViewController(nibName: "ModalPresentationViewController", bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .skeleton:
            let controller = SkeletonViewController(nibName: "SkeletonViewController",
                                                    bundle: Bundle.main)
            navigationController?.pushViewController(controller, animated: true)
        case .modalDraggable:
            let child = ChildViewController()
            let style = DraggableController.DraggableStyle(backgroundColor: .clear, headerViewBackgroundColor: .white, headerViewHeight: 30, panViewBackgroundColor: .gray, panViewSize: CGSize(width: 100, height: 10), topHeaderCornerRadius: 10)
            let modalDraggablle = DraggableController(child: child, style: style)
            navigationController?.present(modalDraggablle, animated: true, completion: nil)
        }
    }
}
