@Library('jenkins-library@feature/UIkit-CD-params-added' ) _

def appPipline = new org.ios.AppPipeline(steps: this, appRootDir: 'Example', appTagDeployment: false, libEnable: true, libAllowWarnings:true)
appPipline.runPipeline('uikit')
