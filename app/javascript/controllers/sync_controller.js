import { Controller } from '@hotwired/stimulus'
import isEqual from 'lodash.isequal'

const inspect = (value) => {
  if (value === undefined) return 'undefined'
  try {
    return JSON.stringify(value, null, 2)
  } catch (_e) {
    return String(value)
  }
}

export default class extends Controller {
  static targets = ["settings"]

  connect () {
    // Add global reference as fallback for electron controller to find us
    window.syncControllerInstance = this
  }

  disconnect () {
    // Clean up global reference
    if (window.syncControllerInstance === this) {
      window.syncControllerInstance = null
    }
  }

  async onElectronReady () {
    await this.setSettings()
  }

  async backup () {
    this.element.classList.add('is-loading')
    try {
      const settings = await window.ElectronBridge.currentSettings()
      let result = await fetch('/settings', {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'X-CSRF-Token': document.querySelector('[name=csrf-token]').content,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          'setting': {
            data: settings
          }
        })
      })
      if (result.status === 401) {
        window.location.href = '/app/v1'
        return
      }
      if (result.ok) {
        window.location.reload()
      }
    } finally {
      this.element.classList.remove('is-loading')
    }
  }

  async restore () {
    this.element.classList.add('is-loading')
    try {
      const remoteSettings = await this.remoteSettings()
      if (remoteSettings === undefined) return
      await window.ElectronBridge.restoreRemoteSettings(remoteSettings.data)
      window.location.reload()
    } finally {
      this.element.classList.remove('is-loading')
    }
  }

  async remoteSettings () {
    let result = await fetch('/settings.json', {
      credentials: 'same-origin',
      method: 'GET'
    })
    if (result.status === 401) {
      window.location.href = '/app/v1'
      return
    }
    if (!result.ok) throw new Error(`Could not read preferences (${result.status})`)
    return await result.json()
  }

  async setSettings () {
    // Clear previous content first
    this.settingsTarget.innerHTML = ''
    
    const stretchlySettings = await window.ElectronBridge.currentSettings()
    
    let remoteSettings = await this.remoteSettings()
    if (remoteSettings === undefined) return
    remoteSettings = remoteSettings || {data: {}}
    
    let keys = Object.assign({}, Object.keys(stretchlySettings))
    if (remoteSettings && remoteSettings.data) {
      Object.assign(keys, Object.keys(remoteSettings.data))
    }
    let allSame = true
    Object.values(keys).forEach((key) => {
      if (!isEqual(stretchlySettings[key], remoteSettings.data[key]) ) {
        allSame = false
        let html = `<div class="box"><h2 class="is-size-5">${key}</h2>`
        html += `<p> <span class="has-text-primary" style="white-space: pre-line">${inspect(stretchlySettings[key])}</span><br/>`
        html += `<span class="has-text-info" style="white-space: pre-line">${inspect(remoteSettings.data[key])}</span></p></div>`
        this.settingsTarget.insertAdjacentHTML('beforeEnd', html)
      }
    })
    if (allSame) {
      let html = `<div class="box"><h2 class="is-size-5">Sweet!</h2>`
      html += `<p>Your Local and Remote preferences are the same. You're all synced up :)</p>`
      this.settingsTarget.insertAdjacentHTML('beforeEnd', html)
    }
  }
}
