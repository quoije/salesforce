trigger UpdateContentDocumentLink on ContentDocumentLink (after insert) {
    Set<Id> contentDocumentIds = new Set<Id>();

    for (ContentDocumentLink cdl : Trigger.new) {
        contentDocumentIds.add(cdl.ContentDocumentId);
    }

    // Query for ContentDocuments related to the inserted ContentDocumentLinks
    List<ContentDocument> contentDocuments = [
        SELECT Id, FileType
        FROM ContentDocument
        WHERE Id IN :contentDocumentIds
    ];

    List<ContentDocumentLink> cdlsToUpdate = new List<ContentDocumentLink>();

    // Loop through the ContentDocumentLinks again to update ShareType based on FileType
    for (ContentDocumentLink cdl : Trigger.new) {
        for (ContentDocument cd : contentDocuments) {
            if (cdl.ContentDocumentId == cd.Id && cd.FileType == 'SNOTE') {
                cdlsToUpdate.add(new ContentDocumentLink(
                    Id = cdl.Id,
                    ShareType = 'I'
                ));
                break; // No need to check further for this ContentDocumentLink
            }
        }
    }

    // Update the ContentDocumentLink records
    if (!cdlsToUpdate.isEmpty()) {
        update cdlsToUpdate;
    }
}