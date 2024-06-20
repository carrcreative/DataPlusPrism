![image](https://github.com/carrcreative/dataplus/assets/173332208/37e0104b-8bfa-4a1c-992b-e78e8a7482d0)





Overview
--------

DataPlus is a lightweight DatastoreService helper, built on the [popular Fusion framework](). DataPlus, when packaged with Fusion, can bring DatastoreService ability to any game immediately. No advanced knowledge needed. 

**Please note:** DataPlus+Fusion packages will be coming out soon

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
    
