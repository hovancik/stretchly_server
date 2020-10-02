import { Controller } from 'stimulus'
const isEqual = require('lodash.isequal')
const util = require('util')

export default class extends Controller {
  static targets = []

  connect () {
    this.setSettings()
  }

  async backup () {
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
    if (result.ok) {
      window.location.reload()
    }
  }

  async restore () {
    const remoteSettings = await this.remoteSettings()
    window.ElectronBridge.restoreRemoteSettings(remoteSettings.data)
  }

  async remoteSettings () {
    let result = await fetch('/settings.json', {
      credentials: 'same-origin',
      method: 'GET'
    })
    return await result.json()
  }

  async setSettings () {
    const stretchlySettings = await window.ElectronBridge.currentSettings()
    let remoteSettings = await this.remoteSettings() || {data: {}}
    let keys = Object.assign({}, Object.keys(stretchlySettings))
    if (remoteSettings && remoteSettings.data) {
      Object.assign(keys, Object.keys(remoteSettings.data))
    }
    let allSame = true
    Object.values(keys).forEach((key) => {
      if (!isEqual(stretchlySettings[key], remoteSettings.data[key]) ) {
        allSame = false
        let html = `<div class="box"><h2 class="is-size-5">${key}</h2>`
        html += `<p> <span class="has-text-primary" style="white-space: pre-line">${util.inspect(stretchlySettings[key], { compact: false, depth: 5 })}</span><br/>`
        html += `<span class="has-text-info" style="white-space: pre-line">${util.inspect(remoteSettings.data[key], { compact: false, depth: 5 })}</span></p></div>`
        document.querySelector('#settings').insertAdjacentHTML('beforeEnd', html)
      }
    })
    if (allSame) {
      let html = `<div class="box"><h2 class="is-size-5">Sweet!</h2>`
      html += `<p>Your Local and Remote preferences are the same. You're all synced up :)</p>`
      document.querySelector('#settings').insertAdjacentHTML('beforeEnd', html)
    }
  }
}
