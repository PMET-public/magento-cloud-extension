// const sampleCmdObj = {
//   text: '',
//   scriptsInValue: [''],
//   additionalEnvVarsInValue: '',
//   suffixToValue: '',
//   tags: ['cloud', 'vm', 'prerequiste', 'magento', 'monitor', 'maintenance', 'access'],
//   help: ''
// }

const commands = [
  {
    text: '1) Install the Cloud CLI',
    scriptsInValue: ['install-cli-and-login.sh'],
    tags: ['prerequiste'],
    help: 'You should only need to run this command on your computer once.'
  },
  {
    text: '2) Setup local ssh keys',
    scriptsInValue: ['setup-ssh-key.sh'],
    tags: ['prerequiste'],
    help: 'You should only need to run this command on your computer once.'
  },
  {
    text: 'SSH',
    scriptsInValue: ['lib.sh', 'ssh.sh'],
    tags: ['cloud', 'vm', 'access'],
    suffixToValue: ' | bash'
  },
  {
    text: 'Backup',
    scriptsInValue: ['lib.sh', 'backup-env.sh', 'maintenance'],
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Unlock admin account',
    scriptsInValue: ['lib.sh', 'admin-unlock.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Create admin account',
    scriptsInValue: ['lib.sh', 'admin-create.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Reindex',
    scriptsInValue: ['lib.sh', 'reindex.sh'],
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
    text: 'Reindex; flush; warm',
    scriptsInValue: ['lib.sh', 'reindex.sh', 'cache-flush.sh', 'cache-warm.sh'],
    tags: ['cloud', 'vm', 'magento'],
  },
  {
    text: 'Check current load',
    scriptsInValue: ['lib.sh', 'check-load.sh'],
    tags: ['cloud', 'vm', 'monitor'],
  },
  {
    text: 'Check services',
    scriptsInValue: ['lib.sh', 'check-services.sh'],
    tags: ['cloud', 'vm', 'monitor'],
  },
  {
    text: 'Copy imgs to env',
    scriptsInValue: ['lib.sh', 'copy-imgs-to-env.sh'],
    tags: ['cloud', 'vm', 'image-copy'],
  },
  {
    text: 'Update Available!',
    scriptsInValue: ['lib.sh', 'update-extension.sh'],
    tags: ['self-update'],
  },
  {
    text: 'Watch logs',
    scriptsInValue: ['lib.sh', 'watch-logs.sh'],
    tags: ['cloud', 'vm', 'monitor'],
  },
  {
    text: 'Install PWA',
    scriptsInValue: ['lib.sh', 'sc-pwa-setup.sh'],
    tags: ['cloud', 'vm', 'magento'],
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
    help: 'All office & VPN IPs will be allowed. You may add 1 more IP temporarily.'
  },
  {
    text: 'Turn email on/off',
    scriptsInValue: ['lib.sh', 'toggle-email.sh'],
    tags: ['cloud', 'vm', 'maintenance'],
  },
  {
    text: 'Deploy a language',
    scriptsInValue: ['lib.sh', 'deploy-lang.sh'],
    tags: ['cloud', 'vm', 'magento'],
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
]