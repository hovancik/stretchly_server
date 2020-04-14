import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'checkbox', 'auth' ]

  connect () {
    this.setDisabled()
  }

  setDisabled () {
    this.authTargets.forEach((el) => {
      el.disabled = !this.checkboxTarget.checked
      if (el.disabled) {
        el.title = "You must agree to the Terms and Conditions and Privacy Policy to continue"
      } else {
        el.title = ""
      }
    })
  }

}
