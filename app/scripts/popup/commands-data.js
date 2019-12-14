// const sampleCmdObj = {
//   text: '',
//   scriptsInValue: [''],
//   tags: ['cloud', 'vm', 'prerequisite', 'magento', 'debug', 'maintenance', 'access'],
//   help: ''
// }

const commands = [

  // prerequisite
  {
    text: '1) Install the Magento Cloud CLI',
    scriptsInValue: ['install-cli-and-login.sh'],
    tags: ['prerequisite'],
    help: 'You should only need to run this command on your computer once.'
  },
  {
    text: '2) Setup your ssh keys',
    scriptsInValue: ['setup-ssh-key.sh'],
    tags: ['prerequisite'],
    help: 'You should only need to run this command on your computer once.'
  },

  // image-copy
  {
    text: 'Copy imgs to env',
    scriptsInValue: ['lib.sh', 'copy-imgs-to-env.sh'],
    tags: ['cloud', 'vm', 'image-copy'],
    help: 'Send images to the remote magento media/import/products folder'
  },

  // self-update
  {
    text: 'Update Available!',
    scriptsInValue: ['lib.sh', 'update-extension.sh'],
    tags: ['self-update'],
    help: 'Get the latest extension features.'
  },

  // magento
  {
    text: 'Create admin account',
    scriptsInValue: ['lib.sh', 'admin-create.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Unlock admin account',
    scriptsInValue: ['lib.sh', 'admin-unlock.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Run cron once',
    scriptsInValue: ['lib.sh', 'run-cron.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Run cron repeatedly',
    scriptsInValue: ['lib.sh', 'run-cron-repeatedly.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Run Magento cron jobs each min for 1 hr'
  },
  {
    text: 'Reindex',
    scriptsInValue: ['lib.sh', 'reindex.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Run all indexes immediately.'
  },
  {
    text: 'Reindex; flush; warm',
    scriptsInValue: ['lib.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Run all indexes immediately. Flush then begin warming all caches.'
  },
  {
    text: 'Warm cache',
    scriptsInValue: ['lib.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Warm (prepopulate) the cache for faster access. A scripte will begin crawling the site.'
  },
  {
    text: 'Flush; then warm cache',
    scriptsInValue: ['lib.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Flush then begin warming all caches.'
  },
  {
    text: 'Install PWA',
    scriptsInValue: ['lib.sh', 'sc-pwa-setup.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Install and run PWA studio locally backed by a cloud env or vm.'
  },
  {
    text: 'Deploy a language',
    scriptsInValue: ['lib.sh', 'deploy-lang.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Choose a languages to deploy from the pre-bundled optioons.'
  },
  {
    text: 'Disable cms cache',
    scriptsInValue: ['lib.sh', 'cache-disable-cms.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Disable relevant caches while setting up the store front.'
  },
  {
    text: 'Enable all caches',
    scriptsInValue: ['lib.sh', 'cache-enable.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Switch to developer mode',
    scriptsInValue: ['lib.sh', 'mode-dev.sh'],
    tags: ['vm', 'magento'],
    help: 'Switch to Magento\'s "developer" mode'
  },
  {
    text: 'Switch to prod mode',
    scriptsInValue: ['lib.sh', 'mode-prod.sh'],
    tags: ['vm', 'magento'],
    help: 'Switch to Magento\'s "productioon" mode'
  },
  // {
  //   text: 'Upgrade modules',
  //   scriptsInValue: ['lib.sh', ''],
  //   tags: ['cloud', 'vm', 'magento'],
  //   help: 'Run upgrade'
  // },

  // debug
  // {
  //   text: 'Diagnose, repair, report',
  //   scriptsInValue: ['lib.sh', 'diagnose-repair-report.sh'],
  //   tags: ['cloud', 'vm', 'debug'],
  //   help: 'Find and attempt to repair common issues. Generate useful debugging info about the env.'
  // },
  {
    text: 'Screen capture',
    scriptsInValue: ['lib.sh', 'screen-capture.sh'],
    tags: ['cloud', 'vm', 'debug'],
    help: 'Quickly snapshot a window. Useful to paste in slack (or anywhere) for support.'
  },
  {
    text: 'Screen record',
    scriptsInValue: ['lib.sh', 'screen-record.sh'],
    tags: ['cloud', 'vm', 'debug'],
    help: 'Record a portion of your screen (plus mic audio) to describe and demo an issue.'
  },
  {
    text: 'Watch logs',
    scriptsInValue: ['lib.sh', 'watch-logs.sh'],
    tags: ['cloud', 'vm', 'debug'],
    help: 'Show access and error logs in real time while accessing the site.'
  },

  // maintenance
  {
    text: 'Backup',
    scriptsInValue: ['lib.sh', 'backup-env.sh', 'maintenance'],
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Turn email on/off',
    scriptsInValue: ['lib.sh', 'toggle-email.sh'],
    tags: ['cloud', 'maintenance'],
    help: 'To enable/disable outgoing emails on cloud, the env must redeploy.'
  },
  {
    text: 'Delete env immediately',
    scriptsInValue: ['lib.sh', 'delete-env.sh'],
    tags: ['cloud', 'maintenance'],
    help: 'Cloud\'s delete only deactivates. Use this to actually delete.'
  },
  {
    text: 'Restore env',
    scriptsInValue: ['lib.sh', 'restore-env.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
    help: 'Immediately restore database and media to previous state using local backup.'
  },
  {
    text: 'Create env from backup',
    scriptsInValue: ['lib.sh', 'create-new-cloud-env-from-backup.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Force rebuild env',
    scriptsInValue: ['lib.sh', 'rebuild-cloud-env.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
    help: 'Some operations (e.g. enabling email) require the env to be rebuilt. Please backup first.'
  },
  {
    text: 'Restart service',
    scriptsInValue: ['lib.sh', ''],
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Update VM v1',
    scriptsInValue: ['lib.sh', 'update-vm.sh'],
    tags: ['vm', 'maintenance'],
    help: 'Apply fixes, compatibility updates, etc. to the vm.'
  },


  // access
  {
    text: 'SSH into env',
    scriptsInValue: ['lib.sh', 'ssh.sh'],
    tags: ['cloud', 'vm', 'access'],
  },
  {
    text: 'Access private repos',
    scriptsInValue: ['lib.sh', 'configure-proxies.sh'],
    tags: ['cloud', 'vm', 'access'],
  },
  {
    text: 'Local access; bypass cloud firewall',
    scriptsInValue: ['lib.sh', 'bypass-waf-for-pb.sh'],
    tags: ['cloud', 'access'],
  },
  {
    text: 'Give another IP access',
    scriptsInValue: ['lib.sh', 'auth-list.enc.sh', 'auth-ip.sh'],
    tags: ['cloud', 'access'],
    help: 'All office & VPN IPs will be allowed. You may add 1 more IP address temporarily.'
  },
  {
    text: 'Show "Authorization" header',
    scriptsInValue: ['lib.sh', 'auth-show.sh'],
    tags: ['cloud', 'access'],
    help: 'This header can be used by applications when passwords are not an option.'
  },

]
