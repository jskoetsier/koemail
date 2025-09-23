import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import toast from 'react-hot-toast';

const Settings = () => {
  const [editingSettings, setEditingSettings] = useState({});
  const queryClient = useQueryClient();

  // Fetch system settings
  const { data: settings, isLoading, error } = useQuery('settings', async () => {
    const response = await axios.get('/api/settings');
    return response.data;
  });

  // Update settings mutation
  const updateSettingMutation = useMutation(
    async ({ key, value }) => {
      const response = await axios.put(`/api/settings/${key}`, { value });
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries('settings');
        setEditingSettings({});
        toast.success('Setting updated successfully');
      },
      onError: (error) => {
        toast.error(error.response?.data?.error || 'Failed to update setting');
      }
    }
  );

  const handleEditSetting = (key, currentValue) => {
    setEditingSettings({
      ...editingSettings,
      [key]: currentValue
    });
  };

  const handleSaveSetting = (key) => {
    updateSettingMutation.mutate({
      key,
      value: editingSettings[key]
    });
  };

  const handleCancelEdit = (key) => {
    const newEditing = { ...editingSettings };
    delete newEditing[key];
    setEditingSettings(newEditing);
  };

  const formatSettingName = (key) => {
    return key
      .split('_')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');
  };

  const getSettingCategory = (key) => {
    if (key.includes('smtp')) return 'SMTP';
    if (key.includes('spam')) return 'Spam Filter';
    if (key.includes('virus')) return 'Antivirus';
    if (key.includes('quota') || key.includes('size')) return 'Storage';
    if (key.includes('backup') || key.includes('retention')) return 'Maintenance';
    if (key.includes('rate') || key.includes('limit')) return 'Limits';
    if (key.includes('dkim') || key.includes('spf') || key.includes('dmarc')) return 'Security';
    return 'General';
  };

  const groupSettingsByCategory = (settings) => {
    const grouped = {};
    settings?.forEach(setting => {
      const category = getSettingCategory(setting.key);
      if (!grouped[category]) {
        grouped[category] = [];
      }
      grouped[category].push(setting);
    });
    return grouped;
  };

  if (isLoading) {
    return (
      <div className="px-4 sm:px-6 lg:px-8">
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="px-4 sm:px-6 lg:px-8">
        <div className="text-center py-12">
          <p className="text-red-500">Error loading settings: {error.message}</p>
        </div>
      </div>
    );
  }

  const groupedSettings = groupSettingsByCategory(settings);

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

      <div className="mt-8 space-y-8">
        {Object.entries(groupedSettings).map(([category, categorySettings]) => (
          <div key={category} className="bg-white shadow rounded-lg">
            <div className="px-6 py-4 border-b border-gray-200">
              <h3 className="text-lg font-medium text-gray-900">{category}</h3>
            </div>
            <div className="px-6 py-4">
              <div className="space-y-4">
                {categorySettings.map((setting) => (
                  <div key={setting.key} className="flex items-center justify-between py-2">
                    <div className="flex-1">
                      <div className="text-sm font-medium text-gray-900">
                        {formatSettingName(setting.key)}
                      </div>
                      {setting.description && (
                        <div className="text-sm text-gray-500">
                          {setting.description}
                        </div>
                      )}
                    </div>
                    <div className="flex items-center space-x-2">
                      {editingSettings[setting.key] !== undefined ? (
                        <>
                          {setting.type === 'boolean' ? (
                            <select
                              value={editingSettings[setting.key]}
                              onChange={(e) => setEditingSettings({
                                ...editingSettings,
                                [setting.key]: e.target.value
                              })}
                              className="rounded-md border-gray-300 text-sm"
                            >
                              <option value="true">True</option>
                              <option value="false">False</option>
                            </select>
                          ) : (
                            <input
                              type={setting.type === 'integer' ? 'number' : 'text'}
                              value={editingSettings[setting.key]}
                              onChange={(e) => setEditingSettings({
                                ...editingSettings,
                                [setting.key]: e.target.value
                              })}
                              className="rounded-md border-gray-300 text-sm w-32"
                            />
                          )}
                          <button
                            onClick={() => handleSaveSetting(setting.key)}
                            disabled={updateSettingMutation.isLoading}
                            className="text-green-600 hover:text-green-900 text-sm"
                          >
                            Save
                          </button>
                          <button
                            onClick={() => handleCancelEdit(setting.key)}
                            className="text-gray-600 hover:text-gray-900 text-sm"
                          >
                            Cancel
                          </button>
                        </>
                      ) : (
                        <>
                          <span className="text-sm text-gray-900 min-w-0 flex-1">
                            {setting.type === 'boolean' 
                              ? (setting.value === 'true' ? 'Yes' : 'No')
                              : setting.value
                            }
                          </span>
                          <button
                            onClick={() => handleEditSetting(setting.key, setting.value)}
                            className="text-blue-600 hover:text-blue-900 text-sm"
                          >
                            Edit
                          </button>
                        </>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      {!settings || settings.length === 0 && (
        <div className="text-center py-12">
          <div className="mx-auto h-12 w-12 text-gray-400">
            ⚙️
          </div>
          <h3 className="mt-2 text-sm font-medium text-gray-900">No settings found</h3>
          <p className="mt-1 text-sm text-gray-500">
            System settings will appear here when available.
          </p>
        </div>
      )}
    </div>
  );
};

export default Settings;