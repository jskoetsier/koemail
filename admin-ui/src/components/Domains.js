import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import toast from 'react-hot-toast';

const Domains = () => {
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [editingDomain, setEditingDomain] = useState(null);
  const queryClient = useQueryClient();

  // Fetch domains
  const { data: domains, isLoading, error } = useQuery('domains', async () => {
    const response = await axios.get('/api/domains');
    return response.data;
  });

  // Create domain mutation
  const createDomainMutation = useMutation(
    async (domainData) => {
      const response = await axios.post('/api/domains', domainData);
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries('domains');
        setShowCreateModal(false);
        toast.success('Domain created successfully');
      },
      onError: (error) => {
        toast.error(error.response?.data?.error || 'Failed to create domain');
      }
    }
  );

  // Update domain mutation
  const updateDomainMutation = useMutation(
    async ({ id, ...domainData }) => {
      const response = await axios.put(`/api/domains/${id}`, domainData);
      return response.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries('domains');
        setEditingDomain(null);
        toast.success('Domain updated successfully');
      },
      onError: (error) => {
        toast.error(error.response?.data?.error || 'Failed to update domain');
      }
    }
  );

  // Delete domain mutation
  const deleteDomainMutation = useMutation(
    async (domainId) => {
      await axios.delete(`/api/domains/${domainId}`);
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries('domains');
        toast.success('Domain deleted successfully');
      },
      onError: (error) => {
        toast.error(error.response?.data?.error || 'Failed to delete domain');
      }
    }
  );

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString();
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
          <p className="text-red-500">Error loading domains: {error.message}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-2xl font-semibold leading-6 text-gray-900">Domains</h1>
          <p className="mt-2 text-sm text-gray-700">
            Manage email domains and their settings
          </p>
        </div>
        <div className="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
          <button
            type="button"
            onClick={() => setShowCreateModal(true)}
            className="block rounded-md bg-blue-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
          >
            Add Domain
          </button>
        </div>
      </div>

      <div className="mt-8 flow-root">
        <div className="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <div className="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
              <table className="min-w-full divide-y divide-gray-300">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Domain
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Description
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Users
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Created
                    </th>
                    <th className="relative px-6 py-3">
                      <span className="sr-only">Actions</span>
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {domains?.map((domain) => (
                    <tr key={domain.id}>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          {domain.domain}
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900">
                          {domain.description || '-'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {domain.user_count || 0}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                          domain.active 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-red-100 text-red-800'
                        }`}>
                          {domain.active ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatDate(domain.created_at)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <button
                          onClick={() => setEditingDomain(domain)}
                          className="text-blue-600 hover:text-blue-900 mr-4"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => {
                            if (window.confirm('Are you sure you want to delete this domain? This will also delete all users in this domain.')) {
                              deleteDomainMutation.mutate(domain.id);
                            }
                          }}
                          className="text-red-600 hover:text-red-900"
                          disabled={domain.user_count > 0}
                        >
                          {domain.user_count > 0 ? 'Has Users' : 'Delete'}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      {domains?.length === 0 && (
        <div className="text-center py-12">
          <div className="mx-auto h-12 w-12 text-gray-400">
            🌐
          </div>
          <h3 className="mt-2 text-sm font-medium text-gray-900">No domains</h3>
          <p className="mt-1 text-sm text-gray-500">
            Get started by creating your first domain.
          </p>
          <div className="mt-6">
            <button
              type="button"
              onClick={() => setShowCreateModal(true)}
              className="inline-flex items-center rounded-md bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
            >
              Add Domain
            </button>
          </div>
        </div>
      )}

      {/* Create Domain Modal */}
      {showCreateModal && (
        <DomainModal
          domain={null}
          onSave={(domainData) => createDomainMutation.mutate(domainData)}
          onClose={() => setShowCreateModal(false)}
          isLoading={createDomainMutation.isLoading}
        />
      )}

      {/* Edit Domain Modal */}
      {editingDomain && (
        <DomainModal
          domain={editingDomain}
          onSave={(domainData) => updateDomainMutation.mutate({ id: editingDomain.id, ...domainData })}
          onClose={() => setEditingDomain(null)}
          isLoading={updateDomainMutation.isLoading}
        />
      )}
    </div>
  );
};

const DomainModal = ({ domain, onSave, onClose, isLoading }) => {
  const [formData, setFormData] = useState({
    domain: domain?.domain || '',
    description: domain?.description || '',
    active: domain?.active !== false
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave(formData);
  };

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <h3 className="text-lg font-bold text-gray-900 mb-4">
          {domain ? 'Edit Domain' : 'Create Domain'}
        </h3>
        
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label className="block text-gray-700 text-sm font-bold mb-2">
              Domain Name
            </label>
            <input
              type="text"
              value={formData.domain}
              onChange={(e) => setFormData({ ...formData, domain: e.target.value })}
              className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
              placeholder="example.com"
              required
              disabled={!!domain} // Disable domain editing for existing domains
              pattern="^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\.[a-zA-Z]{2,}$"
              title="Please enter a valid domain name (e.g., example.com)"
            />
            {!domain && (
              <p className="text-xs text-gray-500 mt-1">
                Enter a valid domain name (e.g., example.com)
              </p>
            )}
          </div>

          <div className="mb-4">
            <label className="block text-gray-700 text-sm font-bold mb-2">
              Description
            </label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
              placeholder="Optional description for this domain"
              rows="3"
            />
          </div>

          <div className="mb-6">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={formData.active}
                onChange={(e) => setFormData({ ...formData, active: e.target.checked })}
                className="mr-2"
              />
              <span className="text-gray-700 text-sm font-bold">Active</span>
            </label>
            <p className="text-xs text-gray-500 mt-1">
              Inactive domains will not accept new email
            </p>
          </div>

          <div className="flex items-center justify-between">
            <button
              type="button"
              onClick={onClose}
              className="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline disabled:opacity-50"
            >
              {isLoading ? 'Saving...' : (domain ? 'Update' : 'Create')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Domains;