# Rspamd workers configuration

# Normal worker for web interface and API
worker "normal" {
  .include "$LOCAL_CONFDIR/local.d/worker-normal.inc"
}

# Proxy worker for milter protocol (used by Postfix)
worker "rspamd_proxy" {
  .include "$LOCAL_CONFDIR/local.d/worker-proxy.inc"
}
