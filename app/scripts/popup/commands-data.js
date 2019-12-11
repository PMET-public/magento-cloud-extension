// const sampleCmdObj = {
//   text: '',
//   scriptsInValue: [''],
//   tags: ['cloud', 'vm', 'prerequisite', 'magento', 'health', 'maintenance', 'access'],
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
  },

  // self-update
  {
    text: 'Update Available!',
    scriptsInValue: ['lib.sh', 'update-extension.sh'],
    tags: ['self-update'],
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
    scriptsInValue: ['lib.sh', 'run-cron.sh'],
    tags: ['cloud', 'vm', 'magento'],
    help: 'Run Magento cron jobs each min for 1 hr'
  },
  {
    text: 'Reindex',
    scriptsInValue: ['lib.sh', 'reindex.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Reindex; flush; warm',
    scriptsInValue: ['lib.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Warm cache',
    scriptsInValue: ['lib.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Flush; then warm cache',
    scriptsInValue: ['lib.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Install PWA',
    scriptsInValue: ['lib.sh', 'sc-pwa-setup.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Deploy a language',
    scriptsInValue: ['lib.sh', 'deploy-lang.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Disable cms cache',
    scriptsInValue: ['lib.sh', 'cache-disable-cms.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Enable all caches',
    scriptsInValue: ['lib.sh', 'cache-enable.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Switch to dev mode',
    scriptsInValue: ['lib.sh', 'mode-dev.sh', 'cache-flush.sh'],
    tags: ['vm', 'magento'],
  },
  {
    text: 'Switch to prod mode',
    scriptsInValue: ['lib.sh', 'mode-prod.sh', 'cache-flush.sh'],
    tags: ['vm', 'magento'],
  },
  {
    text: 'Upgrade modules',
    scriptsInValue: ['lib.sh', ''],
    tags: ['cloud', 'vm', 'magento'],
  },

  // health
  {
    text: 'Check current load',
    scriptsInValue: ['lib.sh', 'check-load.sh'],
    tags: ['cloud', 'vm', 'health'],
  },
  {
    text: 'Check services',
    scriptsInValue: ['lib.sh', 'check-services.sh'],
    tags: ['cloud', 'vm', 'health'],
  },
  {
    text: 'Watch logs',
    scriptsInValue: ['lib.sh', 'watch-logs.sh'],
    tags: ['cloud', 'vm', 'health'],
  },
  {
    text: 'Diagnose and report',
    scriptsInValue: ['lib.sh', 'diagnose.sh'],
    tags: ['cloud', 'vm', 'health'],
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
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Delete env immediately',
    scriptsInValue: ['lib.sh', 'delete-env.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
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


  // access
  {
    text: 'SSH',
    scriptsInValue: ['lib.sh', 'ssh.sh'],
    tags: ['cloud', 'vm', 'access'],
  },
  {
    text: 'Access private repos',
    scriptsInValue: ['lib.sh', 'configure-proxies.sh'],
    tags: ['cloud', 'vm', 'access'],
  },
  {
    text: 'Local access; bypass firewall',
    scriptsInValue: ['lib.sh', 'bypass-waf-for-pb.sh'],
    tags: ['cloud', 'vm', 'access'],
  },
  {
    text: 'Enable password access',
    scriptsInValue: ['lib.sh', 'auth-pass.sh'],
    tags: ['cloud', 'vm', 'access'],
    help: 'Username will be "admin". Password will be the project id.'
  },
  {
    text: 'Enable IP based access',
    scriptsInValue: ['lib.sh', 'auth-list.enc.sh', 'auth-ip.sh'],
    tags: ['cloud', 'vm', 'access'],
    help: 'All office & VPN IPs will be allowed. You may add 1 more IP address temporarily.'
  },
  {
    text: 'Show "Authorization" header',
    scriptsInValue: ['lib.sh', 'auth-show.sh'],
    tags: ['cloud', 'vm', 'access'],
    help: 'This header can be used by applications when passwords are not an option.'
  },

]
