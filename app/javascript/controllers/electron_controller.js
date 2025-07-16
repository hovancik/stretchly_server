import { Controller } from 'stimulus'
const semver = require('semver')

export default class extends Controller {
  static targets = [ 'visible', 'unsupported', 'loader' ]
  static values = { minimalStretchlyVersion: String, isContributor: Boolean }

  connect () {
    this.checkElectronBridge()
  }

  checkElectronBridge () {
    if (window.ElectronBridge) {
      this.hideLoader()
      this.showContent()
      this.setUnsupported()
      this.setContributor()
      
      // Only try to communicate with sync controller if we're on a page that has it
      setTimeout(() => {
        const syncController = window.syncControllerInstance
        if (syncController && syncController.onElectronReady) {
          syncController.onElectronReady()
        }
      }, 50)
    } else {
      this.showLoader()
      this.hideContent()
      // Check again after a short delay - will continue indefinitely
      setTimeout(() => this.checkElectronBridge(), 100)
    }
  }

  showLoader () {
    this.loaderTargets.forEach((el) => {
      el.style.display = ''
    })
  }

  hideLoader () {
    this.loaderTargets.forEach((el) => {
      el.style.display = 'none'
    })
  }

  showContent () {
    this.visibleTargets.forEach((el) => {
      el.style.display = ''
    })
  }

  hideContent () {
    this.visibleTargets.forEach((el) => {
      el.style.display = 'none'
    })
  }

  async setUnsupported () {
    const minVersion = this.minimalStretchlyVersionValue
    const version = !!window.ElectronBridge ? await window.ElectronBridge.stretchlyVersion() : '0'
    this.unsupportedTargets.forEach((el) => {
      el.style.display = semver.gte(version, minVersion) ? 'none' : ''
    })
  }

  setContributor () {
    if (this.hasIsContributorValue && this.isContributorValue) {
      window.ElectronBridge.setContributor()
    }
  }
}
