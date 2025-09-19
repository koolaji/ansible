# GitLab Geo Primary Configuration (Promoted from Secondary)
# This was previously a secondary node, now promoted to primary

external_url 'http://gitlab-secondary'

# PRIMARY ROLE CONFIGURATION - CHANGED FROM SECONDARY
roles ['geo_primary_role']  # Changed from geo_secondary_role
gitlab_rails['geo_node_name'] = 'Secondary GitLab'  # Keep existing name
gitlab_rails['geo_primary_role'] = true  # Add primary role
gitlab_rails['geo_enabled'] = true

# Explicitly set GitLab Edition and ensure Geo is loaded
gitlab_rails['gitlab_edition'] = 'EE'
gitlab_rails['ee_features'] = true

# Environment variables for EE features
gitlab_rails['env'] = {
  'GITLAB_ENABLE_GEO' => 'true',
  'ENABLE_EE_FEATURES' => 'true',
  'GITLAB_LICENSE_MODE' => 'test',
  'GEO_NODE_NAME' => 'Secondary GitLab'
  # REMOVED: 'GITLAB_RAILS_DATABASE_READONLY' => 'true'
}

# ============================================
# MAIN POSTGRESQL CONFIGURATION (GitLab Data)
# ============================================
# ENABLED: Local PostgreSQL (was disabled when secondary)
postgresql['enable'] = true  # Changed from false
postgresql['listen_address'] = '*'
postgresql['port'] = 5432

# Essential WAL settings for Geo replication (as new primary)
postgresql['wal_level'] = 'replica'
postgresql['max_wal_senders'] = 16
postgresql['wal_keep_size'] = '2GB'
postgresql['max_replication_slots'] = 8
postgresql['hot_standby'] = 'on'
postgresql['hot_standby_feedback'] = 'on'

# Disable SSL for testing
postgresql['ssl'] = 'off'

# Geo replication user for main PostgreSQL
postgresql['sql_replication_user'] = 'gitlab_replicator'
postgresql['sql_replication_password'] = 'replication_password_456'

# pg_hba.conf entries for allowing connections
postgresql['custom_pg_hba_entries'] = {
  # Local connections
  'local' => [
    {
      'type' => 'host',
      'database' => 'all',
      'user' => 'all',
      'cidr' => '127.0.0.1/32',
      'method' => 'trust'
    },
    {
      'type' => 'host',
      'database' => 'all',
      'user' => 'all',
      'cidr' => '::1/128',
      'method' => 'trust'
    }
  ],
  # Replication connections
  'replication' => [
    {
      'type' => 'host',
      'database' => 'replication',
      'user' => 'gitlab_replicator',
      'cidr' => '0.0.0.0/0',
      'method' => 'md5'
    }
  ],
  # Database connections
  'database' => [
    {
      'type' => 'host',
      'database' => 'gitlabhq_production',
      'user' => 'gitlab_replicator',
      'cidr' => '0.0.0.0/0',
      'method' => 'md5'
    },
    {
      'type' => 'host',
      'database' => 'gitlabhq_production', 
      'user' => 'gitlab',
      'cidr' => '0.0.0.0/0',
      'method' => 'md5'
    }
  ]
}

# Performance tuning for Geo workload
postgresql['shared_buffers'] = "256MB"
postgresql['effective_cache_size'] = "1GB"
postgresql['work_mem'] = "16MB"
postgresql['maintenance_work_mem'] = "64MB"
postgresql['max_connections'] = 200

# WAL archiving (important for Geo)
postgresql['archive_mode'] = 'on'
postgresql['archive_command'] = '/bin/true'  # Set proper archive command in production

# Checkpoint and WAL settings
postgresql['checkpoint_completion_target'] = 0.9
postgresql['wal_buffers'] = '16MB'
postgresql['checkpoint_timeout'] = '5min'

# ============================================
# REMOVED: REMOTE DATABASE CONNECTION SETTINGS
# ============================================
# These were used when this was a secondary, now removed:
# gitlab_rails['db_host'] = 'gitlab-primary'
# gitlab_rails['db_port'] = 5432
# gitlab_rails['db_username'] = 'gitlab_replicator'
# gitlab_rails['db_password'] = 'replication_password_456'
# gitlab_rails['db_database'] = 'gitlabhq_production'
# gitlab_rails['db_replication_slot'] = 'geo_secondary_slot'
# gitlab_rails['db_adapter'] = 'postgresql'
# gitlab_rails['db_encoding'] = 'unicode'
# gitlab_rails['db_sslmode'] = 'disable'

# ============================================
# READ-WRITE SETTINGS (CHANGED FROM READ-ONLY)
# ============================================
# REMOVED: gitlab_rails['db_read_only'] = true
# REMOVED: gitlab_rails['auto_migrate'] = false
# REMOVED: gitlab_rails['db_connect_later'] = true
# REMOVED: gitlab_rails['db_initialize_with'] = 'SET default_transaction_read_only TO on; SET transaction_read_only TO on;'

# Enable migrations and read-write mode
gitlab_rails['auto_migrate'] = true  # Enable database migrations
gitlab_rails['db_read_only'] = false  # Enable database writes

# ============================================
# GEO POSTGRESQL CONFIGURATION (Geo Tracking)
# ============================================
# Keep the local tracking database
geo_postgresql['enable'] = true
geo_postgresql['listen_address'] = '*'
geo_postgresql['port'] = 5431
geo_postgresql['md5_auth_cidr_addresses'] = ['127.0.0.1/32', '172.0.0.0/8', '192.168.0.0/16', '10.0.0.0/8']
geo_postgresql['trust_auth_cidr_addresses'] = ['127.0.0.1/32']

# Configure Geo tracking database connection - LOCAL ONLY
gitlab_rails['geo_db_adapter'] = 'postgresql'
gitlab_rails['geo_db_host'] = '127.0.0.1'
gitlab_rails['geo_db_port'] = 5431
gitlab_rails['geo_db_database'] = 'gitlabhq_geo_production'
gitlab_rails['geo_db_username'] = 'gitlab_replicator'
gitlab_rails['geo_db_password'] = '1809ad612ad217ba8d058d975bf1df0d'
#gitlab_rails['geo_db_password'] = 'replication_password_456'
gitlab_rails['geo_db_fdw'] = true
gitlab_rails['geo_db_schema'] = 'gitlab_geo'
gitlab_rails['geo_db_encoding'] = 'unicode'

# Add replication settings for geo-postgresql (as primary)
geo_postgresql['wal_level'] = 'replica'
geo_postgresql['max_wal_senders'] = 16
geo_postgresql['wal_keep_size'] = '2GB'
geo_postgresql['max_replication_slots'] = 8
geo_postgresql['hot_standby'] = 'on'
geo_postgresql['hot_standby_feedback'] = 'on'
geo_postgresql['ssl'] = 'off'

# Geo replication user for geo-postgresql
geo_postgresql['sql_replication_user'] = 'gitlab_replicator'
geo_postgresql['sql_replication_password'] = 'replication_password_456'

# pg_hba.conf for geo-postgresql
geo_postgresql['custom_pg_hba_entries'] = {
  'local' => [
    {
      'type' => 'host',
      'database' => 'all',
      'user' => 'all',
      'cidr' => '127.0.0.1/32',
      'method' => 'trust'
    },
    {
      'type' => 'host',
      'database' => 'all',
      'user' => 'all',
      'cidr' => '::1/128',
      'method' => 'trust'
    }
  ],
  'replication' => [
    {
      'type' => 'host',
      'database' => 'replication',
      'user' => 'gitlab_replicator',
      'cidr' => '0.0.0.0/0',
      'method' => 'md5'
    }
  ],
  'database' => [
    {
      'type' => 'host',
      'database' => 'all',
      'user' => 'gitlab_geo_psql',
      'cidr' => '0.0.0.0/0',
      'method' => 'md5'
    },
    {
      'type' => 'host',
      'database' => 'all',
      'user' => 'gitlab_replicator',
      'cidr' => '0.0.0.0/0',
      'method' => 'md5'
    }
  ]
}

# ============================================
# PRIMARY-SPECIFIC GEO SETTINGS
# ============================================
# Enable all Geo replication features (as primary)
gitlab_rails['geo_registry_replication_enabled'] = true
gitlab_rails['geo_repository_verification_enabled'] = true
gitlab_rails['geo_verification_enabled'] = true
gitlab_rails['geo_file_download_dispatch_worker_cron'] = "*/10 * * * *"
gitlab_rails['geo_sync_worker_cron'] = "*/5 * * * *"

# ============================================
# SERVICES CONFIGURATION
# ============================================
# Fix the authorized_keys issue
gitlab_rails['authorized_keys_enabled'] = false

# Configure Gitaly
gitaly['enable'] = true
gitaly['configuration'] = {
  storage: [
    {
      name: 'default',
      path: '/var/opt/gitlab/git-data/repositories'
    }
  ]
}

# Redis configuration (local)
redis['enable'] = true
redis['unixsocket'] = false
redis['bind'] = '0.0.0.0'
redis['port'] = 6379
redis['save'] = []
redis['appendonly'] = 'no'

# Use local Redis
gitlab_rails['redis_host'] = '127.0.0.1'
gitlab_rails['redis_port'] = 6379

# Enable required services
gitlab_workhorse['enable'] = true
sidekiq['enable'] = true
nginx['enable'] = true

# Nginx configuration
nginx['client_max_body_size'] = '250m'

# REMOVED: geo_logcursor (not needed for primary)
# geo_logcursor['enable'] = true

# Enable Prometheus monitoring (re-enabled for primary)
prometheus_monitoring['enable'] = true
prometheus['enable'] = true
node_exporter['enable'] = true
alertmanager['enable'] = false  # Keep disabled if causing issues

# Set proper permissions
manage_accounts['enable'] = true
manage_storage_directories['enable'] = true

# Database performance settings
gitlab_rails['db_prepared_statements'] = false
gitlab_rails['db_statements_limit'] = 1000

# REMOVED: Skip writable check (not needed for primary)
# gitlab_rails['env']['GITLAB_GEO_SKIP_WRITABLE_CHECK'] = 'true'

# ============================================
# LOGGING CONFIGURATION
# ============================================
# Enhanced logging for troubleshooting
logging['svlogd_size'] = 200 * 1024 * 1024  # 200 MB
logging['svlogd_num'] = 30

# Disable extra analytics
gitlab_rails['extra_google_analytics_id'] = nil
gitlab_rails['extra_piwik_url'] = nil
gitlab_rails['extra_piwik_site_id'] = nil
