#!/usr/bin/env node

/**
 * Farm Management System - Health Check System
 * Quick diagnostic tool to check system status
 */

const http = require('http');
const { exec } = require('child_process');

class HealthChecker {
  constructor() {
    this.services = {
      backend: {
        name: 'Backend API',
        url: 'http://localhost:3000/api/health',
        port: 3000,
        expectedResponse: { status: 'OK' }
      },
      frontend: {
        name: 'Flutter Web',
        url: 'http://localhost:8096',
        port: 8096,
        expectedResponse: null // Just check if responds
      }
    };
  }

  async checkUrl(url, timeout = 5000) {
    return new Promise((resolve) => {
      const request = http.get(url, (res) => {
        let data = '';
        
        res.on('data', (chunk) => {
          data += chunk;
        });
        
        res.on('end', () => {
          try {
            const jsonData = JSON.parse(data);
            resolve({
              success: true,
              statusCode: res.statusCode,
              data: jsonData,
              responseTime: Date.now() - startTime
            });
          } catch (e) {
            resolve({
              success: true,
              statusCode: res.statusCode,
              data: data,
              responseTime: Date.now() - startTime
            });
          }
        });
      });
      
      const startTime = Date.now();
      
      request.on('error', (error) => {
        resolve({
          success: false,
          error: error.message,
          responseTime: Date.now() - startTime
        });
      });
      
      request.setTimeout(timeout, () => {
        request.abort();
        resolve({
          success: false,
          error: 'Timeout',
          responseTime: timeout
        });
      });
    });
  }

  async checkPort(port) {
    return new Promise((resolve) => {
      exec(`netstat -an | findstr :${port}`, (error, stdout) => {
        if (error) {
          resolve(false);
        } else {
          resolve(stdout.includes(`0.0.0.0:${port}`) || stdout.includes(`127.0.0.1:${port}`));
        }
      });
    });
  }

  async checkProcesses() {
    return new Promise((resolve) => {
      exec('tasklist', (error, stdout) => {
        if (error) {
          resolve({ node: false, dart: false });
        } else {
          resolve({
            node: stdout.includes('node.exe'),
            dart: stdout.includes('dart.exe')
          });
        }
      });
    });
  }

  formatStatus(status) {
    if (status.success) {
      return `✅ ${status.responseTime}ms`;
    } else {
      return `❌ ${status.error}`;
    }
  }

  async runHealthCheck() {
    console.log('🔍 Farm Management System - Health Check');
    console.log('==========================================');
    console.log();

    // Check processes
    console.log('📊 Process Status:');
    const processes = await this.checkProcesses();
    console.log(`   Node.js: ${processes.node ? '✅ Running' : '❌ Not running'}`);
    console.log(`   Dart:    ${processes.dart ? '✅ Running' : '❌ Not running'}`);
    console.log();

    // Check ports
    console.log('🔌 Port Status:');
    const backendPort = await this.checkPort(3000);
    const frontendPort = await this.checkPort(8096);
    console.log(`   Port 3000 (Backend):  ${backendPort ? '✅ Open' : '❌ Closed'}`);
    console.log(`   Port 8096 (Frontend): ${frontendPort ? '✅ Open' : '❌ Closed'}`);
    console.log();

    // Check service health
    console.log('🌐 Service Health:');
    
    for (const [key, service] of Object.entries(this.services)) {
      const status = await this.checkUrl(service.url);
      console.log(`   ${service.name}: ${this.formatStatus(status)}`);
      
      if (status.success && status.data) {
        if (typeof status.data === 'object') {
          console.log(`      Response: ${JSON.stringify(status.data)}`);
        }
      }
    }
    
    console.log();

    // Overall status
    const backendHealthy = await this.checkUrl(this.services.backend.url);
    const frontendHealthy = await this.checkUrl(this.services.frontend.url);
    
    if (backendHealthy.success && frontendHealthy.success) {
      console.log('🎉 System Status: ALL SYSTEMS OPERATIONAL');
      console.log('   🌐 Frontend: http://localhost:8096');
      console.log('   🔧 Backend:  http://localhost:3000/api/health');
    } else {
      console.log('⚠️  System Status: ISSUES DETECTED');
      
      if (!backendHealthy.success) {
        console.log('   ❌ Backend is not responding');
        console.log('   💡 Try: node scripts\\server-monitor.js restart');
      }
      
      if (!frontendHealthy.success) {
        console.log('   ❌ Frontend is not responding');
        console.log('   💡 Try: scripts\\quick-restart.bat');
      }
    }
    
    console.log();
    console.log('==========================================');
    
    return {
      backend: backendHealthy.success,
      frontend: frontendHealthy.success,
      processes,
      ports: { backend: backendPort, frontend: frontendPort }
    };
  }

  async quickFix() {
    console.log('🔧 Running Quick Fix...');
    console.log();
    
    const health = await this.runHealthCheck();
    
    if (!health.backend || !health.frontend) {
      console.log('🚨 Issues detected, attempting automatic fix...');
      
      return new Promise((resolve) => {
        exec('scripts\\quick-restart.bat', (error, stdout, stderr) => {
          if (error) {
            console.log('❌ Automatic fix failed:', error.message);
            console.log('💡 Please run: scripts\\quick-restart.bat manually');
          } else {
            console.log('✅ Automatic fix completed');
          }
          resolve();
        });
      });
    } else {
      console.log('✅ No issues detected, system is healthy');
    }
  }
}

// CLI Interface
if (require.main === module) {
  const checker = new HealthChecker();
  const command = process.argv[2];
  
  switch (command) {
    case 'check':
    case undefined:
      checker.runHealthCheck();
      break;
      
    case 'fix':
      checker.quickFix();
      break;
      
    default:
      console.log(`
Farm Management System - Health Checker

Usage:
  node health-check.js         # Run health check
  node health-check.js check   # Run health check
  node health-check.js fix     # Run health check and auto-fix issues
      `);
  }
}

module.exports = HealthChecker;
