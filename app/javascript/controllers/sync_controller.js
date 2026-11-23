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
      const result = await fetch('/settings', {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'X-CSRF-Token': document.querySelector('[name=csrf-token]').content,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ setting: { data: settings } })
      })
      // On 401 the Sync page redirects to its own version's login on reload.
      if (result.ok || result.status === 401) window.location.reload()
    } finally {
      this.element.classList.remove('is-loading')
    }
  }

  async restore () {
    this.element.classList.add('is-loading')
    try {
      const remoteSettings = await this.remoteSettings()
      if (!remoteSettings) return
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
    if (result.status === 401) window.location.reload()
    if (!result.ok) return
    return await result.json()
  }

  async setSettings () {
    // Clear previous content first
    this.settingsTarget.innerHTML = ''
    
    const stretchlySettings = await window.ElectronBridge.currentSettings()
    
    const remoteSettings = await this.remoteSettings()
    if (remoteSettings === undefined) return
    const remoteData = remoteSettings?.data ?? {}
    
    const keys = new Set([...Object.keys(stretchlySettings), ...Object.keys(remoteData)])
    let allSame = true
    keys.forEach((key) => {
      if (!isEqual(stretchlySettings[key], remoteData[key])) {
        allSame = false
        const box = document.createElement('div')
        box.className = 'box'
        box.innerHTML = `
          <h2 class="is-size-5"></h2>
          <p>
            <span class="has-text-primary" style="white-space: pre-line"></span><br/>
            <span class="has-text-info" style="white-space: pre-line"></span>
          </p>`
        box.querySelector('h2').textContent = key
        box.querySelector('.has-text-primary').textContent = inspect(stretchlySettings[key])
        box.querySelector('.has-text-info').textContent = inspect(remoteData[key])
        this.settingsTarget.append(box)
      }
    })
    if (allSame) {
      let html = `<div class="box"><h2 class="is-size-5">Sweet!</h2>`
      html += `<p>Your Local and Remote preferences are the same. You're all synced up :)</p>`
      this.settingsTarget.insertAdjacentHTML('beforeEnd', html)
    }
  }
}
