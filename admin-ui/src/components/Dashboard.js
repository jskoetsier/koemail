import React from 'react';
import { useQuery } from 'react-query';
import axios from 'axios';

const Dashboard = () => {
  // Fetch dashboard statistics
  const { data: stats, isLoading: statsLoading } = useQuery('stats', async () => {
    const response = await axios.get('/api/stats');
    return response.data;
  });

  // Fetch user profile for welcome message
  const { data: profile } = useQuery('profile', async () => {
    const response = await axios.get('/api/auth/profile');
    return response.data;
  });

  const formatBytes = (bytes) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  if (statsLoading) {
    return (
      <div className="px-4 sm:px-6 lg:px-8">
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-2xl font-semibold leading-6 text-gray-900">Dashboard</h1>
          <p className="mt-2 text-sm text-gray-700">
            Welcome back, {profile?.name || 'Administrator'}! Here's your KoeMail server overview.
          </p>
        </div>
      </div>

      <div className="mt-8 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {/* Stats cards */}
        <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
          <dt className="truncate text-sm font-medium text-gray-500">Total Users</dt>
          <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
            {stats?.users || 0}
          </dd>
        </div>

        <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
          <dt className="truncate text-sm font-medium text-gray-500">Active Domains</dt>
          <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
            {stats?.domains || 0}
          </dd>
        </div>

        <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
          <dt className="truncate text-sm font-medium text-gray-500">Total Aliases</dt>
          <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
            {stats?.aliases || 0}
          </dd>
        </div>

        <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
          <dt className="truncate text-sm font-medium text-gray-500">Storage Used</dt>
          <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
            {formatBytes(stats?.storage || 0)}
          </dd>
        </div>
      </div>

      <div className="mt-8 grid grid-cols-1 gap-5 lg:grid-cols-2">
        {/* Quick Start */}
        <div className="overflow-hidden rounded-lg bg-white shadow">
          <div className="p-6">
            <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
              🚀 Quick Start
            </h3>
            <div className="prose text-sm text-gray-600">
              <p>Your KoeMail server is running and ready for configuration!</p>
              <ul className="mt-4 space-y-2">
                <li>• Create users in the <a href="/users" className="text-blue-600 hover:text-blue-500">Users section</a></li>
                <li>• Configure domains and aliases in <a href="/domains" className="text-blue-600 hover:text-blue-500">Domains</a></li>
                <li>• Access webmail at <a href="http://koetsier.it:8080" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-500">http://koetsier.it:8080</a></li>
                <li>• Check server settings and monitoring in <a href="/settings" className="text-blue-600 hover:text-blue-500">Settings</a></li>
              </ul>
            </div>
          </div>
        </div>

        {/* System Status */}
        <div className="overflow-hidden rounded-lg bg-white shadow">
          <div className="p-6">
            <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
              ⚡ System Status
            </h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Email Server</span>
                <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                  Running
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Database</span>
                <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                  Connected
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Spam Filter</span>
                <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                  Active
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">Antivirus</span>
                <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                  Active
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="mt-8">
        <div className="overflow-hidden rounded-lg bg-white shadow">
          <div className="p-6">
            <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
              📊 Server Information
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <h4 className="text-sm font-medium text-gray-900 mb-2">Email Protocols</h4>
                <ul className="text-sm text-gray-600 space-y-1">
                  <li>• SMTP: Port 25, 587 (TLS), 465 (SSL)</li>
                  <li>• IMAP: Port 143 (STARTTLS), 993 (SSL)</li>
                  <li>• POP3: Port 110 (STARTTLS), 995 (SSL)</li>
                  <li>• ManageSieve: Port 4190</li>
                </ul>
              </div>
              <div>
                <h4 className="text-sm font-medium text-gray-900 mb-2">Security Features</h4>
                <ul className="text-sm text-gray-600 space-y-1">
                  <li>• Rspamd spam filtering</li>
                  <li>• ClamAV antivirus scanning</li>
                  <li>• TLS/SSL encryption</li>
                  <li>• PostgreSQL backend security</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;