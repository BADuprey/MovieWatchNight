# Import
Add this at the top of file
```
import UIKit
```

# Variable
Add this with the other variables 
```
@State private var copyButtonLabel = "Link to Add Members"
```

# Button
Add right before List(members)... (after the first VStack)
```
Button(action: copyLinkToClipboard) {Text(copyButtonLabel)}
```
# Function
Add in DetailedGroupView Struct, with the other private functions
```
private func copyLinkToClipboard(){
  UIPasteboard.general.string = ServerConfig.shared.baseURLString + "/joinGroup/" + String(group.groupID)
  copyBurronLabel = "Link Copied!"
}
```
