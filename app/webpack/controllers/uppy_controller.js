import { Controller } from 'stimulus'

const Uppy = require('@uppy/core')
const Dashboard = require('@uppy/dashboard')
const XHRUpload = require('@uppy/xhr-upload')

export default class extends Controller {
  static targets = ['url', 'trigger']

  connect() {
    const url = this.urlTarget.value
    const csrf_token = document.querySelector("meta[name='csrf-token']").content

    this.triggerTarget.classList.add('uppy-trigger')

    const uppy = Uppy({
      debug: true,
      autoProceed: false,
      restrictions: {
        maxFileSize: 1000000,
        maxNumberOfFiles: 1,
        minNumberOfFiles: 1,
        allowedFileTypes: ['text/csv'],
      },
    })
      .use(Dashboard, {
        trigger: '.uppy-trigger',
        inline: false,
        showProgressDetails: true,
        note: 'One CSV file only, up to 1 MB',
        height: 470,
        browserBackButtonClose: true,
      })
      .use(XHRUpload, {
        endpoint: url,
        bundle: true,
        headers: {
          'X-CSRF-Token': csrf_token,
        },
      })
    // uppy.on('complete', result => {
    //   console.log('successful files:', result.successful)
    //   console.log('failed files:', result.failed)
    // })
  }
}
