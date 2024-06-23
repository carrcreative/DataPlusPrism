![image](https://github.com/carrcreative/Data-Fusion/assets/173332208/77886bda-897e-4a04-82f3-f6e10d8d6218)







Overview
--------

DataPlus is a lightweight Roblox DatastoreService helper, built on the [popular Fusion framework](https://github.com/carrcreative/fusion/). DataPlus, when packaged with Fusion, can bring DatastoreService ability to any game immediately. No advanced knowledge needed. 

[Get the Roblox model available on the Creator Store!](https://create.roblox.com/store/asset/18158091161/DataPlusFusion?viewFromStudio=true&keyword=&searchId=7c9974fc-b875-4042-ad28-08cfe4f01028)

[Our latest binaries available for download.](https://github.com/carrcreative/Data-Fusion/releases/tag/pre-release) 

API Functions
-------------

### GetData(Scope)

Retrieves the data associated with the given scope.

*   **Parameters**:
    *   `Scope`: String to save data value under.
*   **Returns**: The data value if found in the cache or datastore.

### SetData(Scope, Value)

Sets the data for the given key and updates the cache.

*   **Parameters**:
    *   `Scope`: String to save data value under.
    *   `Value`: The new value to set.
*   **Returns**: `true` if the operation is successful.

### GetVersions(Scope)

Fetches the version history of the data for rollback purposes.

*   **Parameters**:
    *   `Scope`: String to save data value under.
*   **Returns**: A table containing the last three versions of the data.

Script Examples
---------------  

### Setting Data

Lua

    Fusion:Post(PrivateKey, "SetData", "PlayerScore", 100) 

### Getting Data

Lua
    
    local PlayerScore = Fusion:Post(PrivateKey, "GetData", "PlayerScore")
    print(PlayerScore)
    
