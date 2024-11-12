module.exports = {
    apps: [{
      name: "print-server",
      script: "./dist/src/index.js",  // Points to the compiled JavaScript
      env: {
        NODE_ENV: "development",
      },
      env_production: {
        NODE_ENV: "production"
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G'
    }]
  }