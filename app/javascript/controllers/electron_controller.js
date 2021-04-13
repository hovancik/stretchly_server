import { Controller } from 'stimulus'
const semver = require('semver')

export default class extends Controller {
  static targets = [ 'visible', 'hidden', 'unsupported' ]
  static values = { minimalStretchlyVersion: String }

  connect () {
    this.setVisible()
    this.setHidden()
    this.setUnsupported()
  }

  setVisible () {
    this.visibleTargets.forEach((el) => {
      el.style.display = !!window.ElectronBridge ? '' : 'none'
    })
  }

  setHidden () {
    this.hiddenTargets.forEach((el) => {
      el.style.display = !!window.ElectronBridge ? 'none' : ''
    })
  }

  setUnsupported () {
    const minVersion = this.minimalStretchlyVersionValue
    const version = !!window.ElectronBridge ? window.ElectronBridge.stretchlyVersion() : '0'
    this.unsupportedTargets.forEach((el) => {
      el.style.display = semver.gte(version, minVersion) ? 'none' : ''
    })
  }
}
