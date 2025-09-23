import React from 'react';

const Settings = () => {
  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-2xl font-semibold leading-6 text-gray-900">Settings</h1>
          <p className="mt-2 text-sm text-gray-700">
            Configure server settings and preferences
          </p>
        </div>
      </div>
      <div className="mt-8 flow-root">
        <div className="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <div className="text-center py-12">
              <p className="text-gray-500">Settings interface will be implemented here</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Settings;