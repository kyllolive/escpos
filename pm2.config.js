module.exports = {
    apps: [{
      name: "print-server",
      script: "./dist/src/index.js",  // Points to the compiled JavaScript
      env: {
        NODE_ENV: "production",
        PORT: 5000
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: "logs/err.log",
      out_file: "logs/out.log",
      log_file: "logs/combined.log",
      time: true,
      // Windows specific settings
      kill_timeout: 3000,
      restart_delay: 3000,
      wait_ready: true,
      max_restarts: 10,
      exp_backoff_restart_delay: 100
    }]
  }