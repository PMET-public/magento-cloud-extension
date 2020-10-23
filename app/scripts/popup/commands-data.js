// const sampleCmdObj = {
//   text: '',
//   scriptsInValue: [''],
//   cmdTypes: ['prerequisite', 'maintenance'],
//   envTypes: ['cloud', 'vm', 'localhost', 'any'],
//   additionalSearchTerms: [],
//   help: ''
// }

const commands = [

  // prerequisite
  {
    id: 'install-cli-and-login',
    text: '1) Install the Magento Cloud CLI',
    scriptsInValue: ['install-cli-and-login.sh'],
    cmdTypes: ['prerequisite'],
    envTypes: ['cloud'],
    help: 'You should only need to run this command on your computer once.'
  },
  {
    id: 'setup-ssh-key',
    text: '2) Setup your ssh keys',
    scriptsInValue: ['setup-ssh-key.sh'],
    cmdTypes: ['prerequisite'],
    envTypes: ['cloud'],
    help: 'You should only need to run this command on your computer once.'
  },

  // image-copy
  {
    id: 'copy-imgs-to-env',
    text: 'Copy imgs to env',
    scriptsInValue: ['lib.sh', 'copy-imgs-to-env.sh'],
    cmdTypes: ['image-copy'],
    envTypes: ['cloud', 'vm'],
    help: 'Send images to the remote magento media/import/products folder'
  },

  // lighthouse
  {
    id: 'run-lighthouse',
    text: 'Run lighthouse',
    scriptsInValue: ['lib.sh', 'run-lighthouse.sh'],
    cmdTypes: ['lighthouse'],
    envTypes: ['cloud', 'vm'],
    help: 'Install and run Google\'s Lighthouse performance tool'
  },

  // self-update
  {
    id: 'update-extension',
    text: 'Update Available!',
    scriptsInValue: ['lib.sh', 'update-extension.sh'],
    cmdTypes: ['self-update'],
    envTypes: ['any'],
    help: 'Get the latest extension features.'
  },

  // magento
  {
    id: 'admin-create',
    text: 'Create admin account',
    scriptsInValue: ['lib.sh', 'admin-create.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'admin-unlock',
    text: 'Unlock admin account',
    scriptsInValue: ['lib.sh', 'admin-unlock.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'run-cron',
    text: 'Run cron once',
    scriptsInValue: ['lib.sh', 'run-cron.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'run-cron-repeatedly',
    text: 'Run cron repeatedly',
    scriptsInValue: ['lib.sh', 'run-cron-repeatedly.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Run Magento cron jobs each min for 1 hr'
  },
  {
    id: 'reindex',
    text: 'Reindex',
    scriptsInValue: ['lib.sh', 'reindex.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Run all indexes immediately.'
  },
  {
    id: 'reindex-flush-warm',
    text: 'Reindex; flush; warm',
    scriptsInValue: ['lib.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Run all indexes immediately. Flush (clean) then begin warming all caches.'
  },
  {
    id: 'cache-warm',
    text: 'Warm cache',
    scriptsInValue: ['lib.sh', 'cache-warm.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Warm (prepopulate) the cache for faster access. A scripte will begin crawling the site.'
  },
  {
    id: 'flush-then-warm',
    text: 'Flush; then warm cache',
    scriptsInValue: ['lib.sh', 'cache-flush.sh', 'cache-warm.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Flush  (clean) then begin warming all caches.'
  },
  {
    id: 'install-pwa',
    text: 'Install PWA',
    scriptsInValue: ['lib.sh', 'sc-pwa-setup.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Install and run PWA studio locally backed by a cloud env or vm.'
  },
  {
    id: 'deploy-language',
    text: 'Deploy a language',
    scriptsInValue: ['lib.sh', 'deploy-lang.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Choose a languages to deploy from the pre-bundled options.'
  },
  {
    id: 'disable-cms-cache',
    text: 'Disable cms cache',
    scriptsInValue: ['lib.sh', 'cache-disable-cms.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Disable relevant caches while setting up the store front.'
  },
  {
    id: 'cache-enable',
    text: 'Enable all caches',
    scriptsInValue: ['lib.sh', 'cache-enable.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'optimize-for-performance',
    text: 'Optimize for performance',
    scriptsInValue: ['lib.sh', 'cache-enable.sh', 'optimize-env-for-performance.sh', 'cache-flush.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Enable all caches. Optimize JS & CSS.'
  },
  {
    id: 'optimize-for-dev',
    text: 'Optimize for dev',
    scriptsInValue: ['lib.sh', 'cache-disable-cms.sh', 'optimize-env-for-customization.sh', 'cache-flush.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Enable all caches. Unbunlde JS & CSS.'
  },
  {
    id: 'dev-mode',
    text: 'Switch to developer mode',
    scriptsInValue: ['lib.sh', 'mode-dev.sh'],
    cmdTypes: ['magento'],
    envTypes: ['vm'],
    help: 'Switch to Magento\'s "developer" mode'
  },
  {
    id: 'prod-mode',
    text: 'Switch to prod mode',
    scriptsInValue: ['lib.sh', 'mode-prod.sh'],
    cmdTypes: ['magento'],
    envTypes: ['vm'],
    help: 'Switch to Magento\'s "production" mode'
  },
  {
    id: 'add-grocery',
    text: 'Add grocery',
    scriptsInValue: ['lib.sh', 'add-grocery.sh', 'reindex-on-schedule.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    cmdTypes: ['magento'],
    envTypes: ['cloud', 'vm'],
    help: 'Add New Grocery Vertical to a Cloud environment.'
  },
  // {
  //   text: 'Upgrade modules',
  //   scriptsInValue: ['lib.sh', ''],
  //   cmdTypes: ['magento'],
  //   envTypes: ['cloud', 'vm'],
  //   help: 'Run upgrade'
  // },

  {
    id: 'diagnose-repair-report',
    text: 'Diagnose, repair, report',
    scriptsInValue: ['lib.sh', 'dl-and-run-drr.sh'],
    cmdTypes: ['debug'],
    envTypes: ['cloud', 'vm'],
    help: 'Find and attempt to repair common issues. Generate useful debugging info about the env.'
  },
  {
    id: 'screen-capture',
    text: 'Screen capture',
    scriptsInValue: ['lib.sh', 'screen-capture.sh'],
    cmdTypes: ['debug'],
    envTypes: ['cloud', 'vm'],
    help: 'Quickly snapshot a window. Useful to paste in slack (or anywhere) for support.'
  },
  {
    id: 'screen-record',
    text: 'Screen record',
    scriptsInValue: ['lib.sh', 'screen-record.sh'],
    cmdTypes: ['debug'],
    envTypes: ['cloud', 'vm'],
    help: 'Record a portion of your screen (plus mic audio) to describe and demo an issue.'
  },
  {
    id: 'watch-logs',
    text: 'Watch logs',
    scriptsInValue: ['lib.sh', 'watch-logs.sh'],
    cmdTypes: ['debug'],
    envTypes: ['cloud', 'vm'],
    help: 'Show access and error logs in real time while accessing the site.'
  },

  // maintenance
  {
    id: 'backup-env',
    text: 'Backup',
    scriptsInValue: ['lib.sh', 'backup-env.sh', 'maintenance'],
    cmdTypes: ['maintenance'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'toggle-email',
    text: 'Turn email on/off',
    scriptsInValue: ['lib.sh', 'toggle-email.sh'],
    cmdTypes: ['maintenance'],
    envTypes: ['cloud'],
    help: 'To enable/disable outgoing emails on cloud, the env must redeploy.'
  },
  {
    id: 'delete-env',
    text: 'Delete env immediately',
    scriptsInValue: ['lib.sh', 'delete-env.sh'],
    cmdTypes: ['maintenance'],
    envTypes: ['cloud'],
    help: 'Cloud\'s delete only deactivates. Use this to actually delete.'
  },
  {
    id: 'restore-env',
    text: 'Restore env',
    scriptsInValue: ['lib.sh', 'restore-env.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    cmdTypes: ['maintenance'],
    envTypes: ['cloud', 'vm'],
    help: 'Immediately restore database and media to previous state using local backup.'
  },
  {
    id: 'create-env-from-backup',
    text: 'Create env from backup',
    scriptsInValue: ['lib.sh', 'create-new-cloud-env-from-backup.sh'],
    cmdTypes: ['maintenance'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'force-rebuild-env',
    text: 'Force rebuild env',
    scriptsInValue: ['lib.sh', 'rebuild-cloud-env.sh'],
    cmdTypes: ['maintenance'],
    envTypes: ['cloud', 'vm'],
    help: 'Some operations (e.g. enabling email) require the env to be rebuilt. Please backup first.'
  },
  {
    id: 'restart-service',
    text: 'Restart service',
    scriptsInValue: ['lib.sh', ''],
    cmdTypes: ['maintenance'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'update-vm',
    text: 'Update VM v1',
    scriptsInValue: ['lib.sh', 'update-vm.sh'],
    cmdTypes: ['maintenance'],
    envTypes: ['vm'],
    help: 'Apply fixes, compatibility updates, etc. to the vm.'
  },

  // access
  {
    id: 'ssh',
    text: 'SSH into env',
    scriptsInValue: ['lib.sh', 'ssh.sh'],
    cmdTypes: ['access'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'access-private-repose',
    text: 'Access private repos',
    scriptsInValue: ['lib.sh', 'configure-proxies.sh'],
    cmdTypes: ['access'],
    envTypes: ['cloud', 'vm'],
  },
  {
    id: 'bypass-firewall',
    text: 'Local access; bypass cloud firewall',
    scriptsInValue: ['lib.sh', 'bypass-waf-for-pb.sh'],
    cmdTypes: ['access'],
    envTypes: ['cloud'],
  },
  {
    id: 'add-ip',
    text: 'Give another IP access',
    scriptsInValue: ['lib.sh', 'auth-list.enc.sh', 'auth-ip.sh'],
    cmdTypes: ['access'],
    envTypes: ['cloud'],
    help: 'All office & VPN IPs will be allowed. You may add 1 more IP address temporarily.'
  },
  {
    id: 'show-auth-header',
    text: 'Show "Authorization" header',
    scriptsInValue: ['lib.sh', 'auth-show.sh'],
    cmdTypes: ['access'],
    envTypes: ['cloud'],
    help: 'This header can be used by applications when passwords are not an option.'
  },

]
