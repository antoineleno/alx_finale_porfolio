document.addEventListener('DOMContentLoaded', function() {
    let propertyIdToDelete = null;
    let propertyElementToDelete = null;

    // Delete property functionality with confirmation modal
    document.getElementById('propertyList').addEventListener('click', function(event) {
        if (event.target.closest('.delete-icon a')) {
            event.preventDefault();
            propertyIdToDelete = event.target.closest('.delete-icon a').getAttribute('data-id');
            propertyElementToDelete = event.target.closest('.property-item');

            // Show the confirmation modal
            const deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmationModal'));
            deleteModal.show();
        }
    });

    // Confirm delete button in modal
    document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
        if (propertyIdToDelete) {
            // AJAX request to delete the property
            fetch(`/wishlist/delete_property/${propertyIdToDelete}`, {
                method: 'DELETE'
            })
            .then(response => {
                if (response.ok) {
                    console.log('Property deleted:', propertyIdToDelete);
                    if (propertyElementToDelete) {
                        propertyElementToDelete.remove();
                    }
                }
            })
            .catch(error => console.error('Error deleting property:', error))
            .finally(() => {
                propertyIdToDelete = null;
                propertyElementToDelete = null;
                window.location.reload();
            });
        }
    });

    // Reload the page when the modal is dismissed
    const deleteConfirmationModal = document.getElementById('deleteConfirmationModal');
    deleteConfirmationModal.addEventListener('hidden.bs.modal', function() {
        window.location.reload();
    });
});
