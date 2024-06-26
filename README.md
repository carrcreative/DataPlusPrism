![image](https://github.com/carrcreative/Data-Fusion/assets/173332208/7ec92e69-1bc4-48b8-8043-6d95b81cb8ec)









Overview
--------

DataPlus is a lightweight Roblox DatastoreService helper, built on the [popular Prism framework](https://github.com/carrcreative/Prism/). DataPlus, when packaged with Prism, can bring DatastoreService ability to any game immediately. No advanced knowledge needed. 

[Data+Prism Creator Edition (Roblox Creator Hub)](https://create.roblox.com/store/asset/18158091161/DataPlusPrism?viewFromStudio=true&keyword=&searchId=7c9974fc-b875-4042-ad28-08cfe4f01028)

[Data+Prism XML Download](https://github.com/carrcreative/Data-Prism/releases/tag/pre-release) 

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

    Prism:f(PrivateKey, "SetData", "PlayerScore", 100) 

### Getting Data

Lua
    
    local PlayerScore = Prism:f(PrivateKey, "GetData", "PlayerScore")
    print(PlayerScore)
    
