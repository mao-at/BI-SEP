from datetime import datetime,timedelta
from azure.storage import blob
from azure.storage.blob import BlobServiceClient, generate_account_sas,ResourceTypes,AccountSasPermissions

def get_blob_sizes(container_service):

    ''' takes: a blob container client
        prints: name, blob type and blob size for all blobs in the container
        returns: none
    '''
    blobs = list(container_service.list_blobs())
    # calculate spacing needed to make things prettier
    max_blob_name_length = max([len(blob.name) for blob in blobs])
    max_blob_type_length = max([len(blob.blob_type) for blob in blobs])
    max_blob_size_length = max([len(str(blob.size)) for blob in blobs])
    stars = max_blob_name_length + max_blob_type_length + max_blob_size_length + 11
    print("*"*stars)
    # format printing
    for blob in blobs:
        print("*  " + "".join((blob.name.ljust(max_blob_name_length + 2), blob.blob_type.ljust(max_blob_type_length+2), str(blob.size).ljust(max_blob_size_length+2)," *")))
    print("*"*stars)

def get_folder_sizes(container_service):

    ''' takes: a blob container client
        prints: a dictionary with folder names as keys and sizes as values
        returns: a dictionary with folder names as keys and sizes as values
    '''
    # get a list of all blobs in the container
    list_of_blobs = list(container_service.list_blobs())
    # get a list of folder names
    folder_names_with_dups = ["/".join(blob.name.split("/")[:-1]) for blob in list_of_blobs]
    folder_names = []
    [folder_names.append(x) for x in folder_names_with_dups if x not in folder_names and len(x)>0]
    # create a dictionary where every folder name is a key and the value is the folder size
    result = {folder:0 for folder in folder_names}
    result["root"] = 0

    for blob in list_of_blobs:
        result["root"] += blob.size
        for folder in folder_names:
            if folder in blob.name:
                result[folder] += blob.size

    print(result)
    return result



if __name__ == "__main__":

    connection_string = "DefaultEndpointsProtocol=https;AccountName=antrablobstorage;AccountKey=1111111111111111111111111111;EndpointSuffix=core.windows.net"
    storage_account_service = BlobServiceClient.from_connection_string(conn_str=connection_string)
    container_service = storage_account_service.get_container_client("imagescontainer")

    # get_blob_sizes(container_service)
    get_folder_sizes(container_service)
    

