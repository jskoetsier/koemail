import React from 'react';

const Dashboard = () => {
  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-2xl font-semibold leading-6 text-gray-900">Dashboard</h1>
          <p className="mt-2 text-sm text-gray-700">
            Overview of your KoeMail server
          </p>
        </div>
      </div>

      <div className="mt-8 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {/* Stats cards */}
        <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
          <dt className="truncate text-sm font-medium text-gray-500">Total Users</dt>
          <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">0</dd>
        </div>

        <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
          <dt className="truncate text-sm font-medium text-gray-500">Domains</dt>
          <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">1</dd>
        </div>

        <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
          <dt className="truncate text-sm font-medium text-gray-500">Storage Used</dt>
          <dd className="mt-1 text-3xl font-semibold tracking-tight text-gray-900">0 MB</dd>
        </div>

        <div className="overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:p-6">
          <dt className="truncate text-sm font-medium text-gray-500">Server Status</dt>
          <dd className="mt-1 text-3xl font-semibold tracking-tight text-green-600">Running</dd>
        </div>
      </div>

      <div className="mt-8">
        <div className="overflow-hidden rounded-lg bg-white shadow">
          <div className="p-6">
            <h3 className="text-lg font-medium leading-6 text-gray-900">Quick Start</h3>
            <div className="mt-4">
              <div className="prose text-sm text-gray-600">
                <p>Welcome to KoeMail! Your email server is running and ready for configuration.</p>
                <ul className="mt-4 space-y-2">
                  <li>• Create users in the Users section</li>
                  <li>• Configure domains and aliases</li>
                  <li>• Access webmail at <a href="http://koetsier.it:8080" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-500">http://koetsier.it:8080</a></li>
                  <li>• Check server settings and monitoring</li>
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