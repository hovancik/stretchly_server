import { Application } from '@hotwired/stimulus'

import ElectronController from './controllers/electron_controller'
import SyncController from './controllers/sync_controller'
import TermsController from './controllers/terms_controller'

const application = Application.start()
application.register('electron', ElectronController)
application.register('sync', SyncController)
application.register('terms', TermsController)

if (navigator.platform.indexOf('Mac') > -1) {
  document.body.classList.add('darwin')
}
