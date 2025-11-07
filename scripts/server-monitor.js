#!/usr/bin/env node

/**
 * Farm Management System - Server Monitor & Auto-Restart
 * Prevents the half-day crisis from happening again
 */

const { exec, spawn } = require('child_process');
const http = require('http');
const path = require('path');
const fs = require('fs');

class ServerMonitor {
  constructor() {
    this.config = {
      backend: {
        name: 'Backend API',
        path: path.join(__dirname, '..', 'backend'),
        script: 'server.js',
        port: 3000,
        healthUrl: 'http://localhost:3000/api/health',
        process: null,
        retries: 0,
        maxRetries: 3
      },
      frontend: {
        name: 'Flutter Web',
        path: path.join(__dirname, '..'),
        command: 'flutter run -d web-server --web-port=8096',
        port: 8096,
        healthUrl: 'http://localhost:8096',
        process: null,
        retries: 0,
        maxRetries: 3
      }
    };
    
    this.checkInterval = 30000; // Check every 30 seconds
    this.isMonitoring = false;
    this.logFile = path.join(__dirname, 'server-monitor.log');
  }

  log(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${message}`;
    console.log(logMessage);
    
    // Write to log file
    fs.appendFileSync(this.logFile, logMessage + '\n');
  }

  async checkHealth(url) {
    return new Promise((resolve) => {
      const request = http.get(url, (res) => {
        resolve(res.statusCode === 200);
      });
      
      request.on('error', () => {
        resolve(false);
      });
      
      request.setTimeout(5000, () => {
        request.abort();
        resolve(false);
      });
    });
  }

  async killExistingProcesses() {
    this.log('🧹 Cleaning existing processes...');
    
    return new Promise((resolve) => {
      // Kill Node.js processes
      exec('taskkill /f /im node.exe', (error) => {
        // Kill Dart processes
        exec('taskkill /f /im dart.exe', (error) => {
          setTimeout(() => {
            this.log('✅ Process cleanup completed');
            resolve();
          }, 3000);
        });
      });
    });
  }

  startBackend() {
    this.log('🚀 Starting Backend Server...');
    
    const backendProcess = spawn('node', ['server.js'], {
      cwd: this.config.backend.path,
      stdio: ['pipe', 'pipe', 'pipe'],
      shell: true
    });

    backendProcess.stdout.on('data', (data) => {
      this.log(`[Backend] ${data.toString().trim()}`);
    });

    backendProcess.stderr.on('data', (data) => {
      this.log(`[Backend Error] ${data.toString().trim()}`);
    });

    backendProcess.on('close', (code) => {
      this.log(`❌ Backend process exited with code ${code}`);
      this.config.backend.process = null;
      
      if (this.isMonitoring && this.config.backend.retries < this.config.backend.maxRetries) {
        this.config.backend.retries++;
        this.log(`🔄 Restarting backend (attempt ${this.config.backend.retries}/${this.config.backend.maxRetries})`);
        setTimeout(() => this.startBackend(), 5000);
      }
    });

    this.config.backend.process = backendProcess;
    return backendProcess;
  }

  startFrontend() {
    this.log('🌐 Starting Flutter Web Server...');
    
    const frontendProcess = spawn('flutter', ['run', '-d', 'web-server', '--web-port=8096'], {
      cwd: this.config.frontend.path,
      stdio: ['pipe', 'pipe', 'pipe'],
      shell: true
    });

    frontendProcess.stdout.on('data', (data) => {
      const output = data.toString().trim();
      this.log(`[Frontend] ${output}`);
      
      // Check if server is ready
      if (output.includes('is being served at')) {
        this.log('✅ Flutter Web Server is ready!');
      }
    });

    frontendProcess.stderr.on('data', (data) => {
      this.log(`[Frontend Error] ${data.toString().trim()}`);
    });

    frontendProcess.on('close', (code) => {
      this.log(`❌ Frontend process exited with code ${code}`);
      this.config.frontend.process = null;
      
      if (this.isMonitoring && this.config.frontend.retries < this.config.frontend.maxRetries) {
        this.config.frontend.retries++;
        this.log(`🔄 Restarting frontend (attempt ${this.config.frontend.retries}/${this.config.frontend.maxRetries})`);
        setTimeout(() => this.startFrontend(), 5000);
      }
    });

    this.config.frontend.process = frontendProcess;
    return frontendProcess;
  }

  async startAllServers() {
    this.log('🎯 Starting Farm Management System...');
    
    // Clean existing processes first
    await this.killExistingProcesses();
    
    // Start backend
    this.startBackend();
    
    // Wait for backend to be ready
    await this.waitForHealth(this.config.backend.healthUrl, 'Backend');
    
    // Start frontend
    this.startFrontend();
    
    // Wait for frontend to be ready
    await this.waitForHealth(this.config.frontend.healthUrl, 'Frontend');
    
    this.log('🎉 All servers are running successfully!');
  }

  async waitForHealth(url, serviceName) {
    this.log(`⏳ Waiting for ${serviceName} to be ready...`);
    
    for (let i = 0; i < 30; i++) { // Wait up to 5 minutes
      if (await this.checkHealth(url)) {
        this.log(`✅ ${serviceName} is healthy!`);
        return true;
      }
      await new Promise(resolve => setTimeout(resolve, 10000)); // Wait 10 seconds
    }
    
    this.log(`❌ ${serviceName} failed to start within timeout`);
    return false;
  }

  async monitorServers() {
    if (!this.isMonitoring) return;
    
    this.log('🔍 Checking server health...');
    
    // Check backend
    const backendHealthy = await this.checkHealth(this.config.backend.healthUrl);
    if (!backendHealthy && this.config.backend.process) {
      this.log('❌ Backend is not responding, restarting...');
      this.config.backend.process.kill();
      this.config.backend.retries = 0;
      setTimeout(() => this.startBackend(), 2000);
    } else if (backendHealthy) {
      this.config.backend.retries = 0; // Reset retries on success
    }
    
    // Check frontend
    const frontendHealthy = await this.checkHealth(this.config.frontend.healthUrl);
    if (!frontendHealthy && this.config.frontend.process) {
      this.log('❌ Frontend is not responding, restarting...');
      this.config.frontend.process.kill();
      this.config.frontend.retries = 0;
      setTimeout(() => this.startFrontend(), 2000);
    } else if (frontendHealthy) {
      this.config.frontend.retries = 0; // Reset retries on success
    }
    
    if (backendHealthy && frontendHealthy) {
      this.log('✅ All servers are healthy');
    }
    
    // Schedule next check
    setTimeout(() => this.monitorServers(), this.checkInterval);
  }

  startMonitoring() {
    this.log('🛡️ Starting server monitoring system...');
    this.isMonitoring = true;
    
    // Start servers first
    this.startAllServers().then(() => {
      // Start monitoring
      setTimeout(() => this.monitorServers(), this.checkInterval);
    });
  }

  stopMonitoring() {
    this.log('🛑 Stopping server monitoring...');
    this.isMonitoring = false;
    
    if (this.config.backend.process) {
      this.config.backend.process.kill();
    }
    
    if (this.config.frontend.process) {
      this.config.frontend.process.kill();
    }
  }

  getStatus() {
    return {
      monitoring: this.isMonitoring,
      backend: {
        running: !!this.config.backend.process,
        retries: this.config.backend.retries
      },
      frontend: {
        running: !!this.config.frontend.process,
        retries: this.config.frontend.retries
      }
    };
  }
}

// CLI Interface
if (require.main === module) {
  const monitor = new ServerMonitor();
  
  const command = process.argv[2];
  
  switch (command) {
    case 'start':
      monitor.startMonitoring();
      break;
      
    case 'stop':
      monitor.stopMonitoring();
      process.exit(0);
      break;
      
    case 'status':
      console.log(JSON.stringify(monitor.getStatus(), null, 2));
      break;
      
    case 'restart':
      monitor.killExistingProcesses().then(() => {
        monitor.startAllServers();
      });
      break;
      
    default:
      console.log(`
Farm Management System - Server Monitor

Usage:
  node server-monitor.js start    # Start monitoring with auto-restart
  node server-monitor.js stop     # Stop all servers and monitoring
  node server-monitor.js status   # Show current status
  node server-monitor.js restart  # Restart all servers
      `);
  }
  
  // Graceful shutdown
  process.on('SIGINT', () => {
    monitor.stopMonitoring();
    process.exit(0);
  });
}

module.exports = ServerMonitor;
