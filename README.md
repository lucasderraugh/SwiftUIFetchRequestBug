### Bug Explanation
When a SwiftUI View is presented that uses `@FetchRequest` and an update occurs while it is presented, it forever retains the backing `SwiftUI.FetchController`.
This is a problem if you go to remove the persistent stores as creating a new persistent store and having changes on that will crash the outstanding fetch controller that has stale assets.

### Steps to reproduce bug
1. Tap "Open SwiftUI View" (At this point observe in memory debugger that 1 instance of SwiftUI.FetchController exists without a retain cycle)
2. Tap "Add new person" in sheet (Now that same object exists but now has a retain cycle)
3. Dismiss the sheet by swiping down
4. Tap Clear DB (wait for "Persistent stores reloaded" in console)
5. Tap "Open SwiftUI View"
6. Tap "Add new person" in sheet
(Observe Core Data throwing an exception)

| Before Adding Entity | After Adding Entity |
|----------------------|---------------------|
| <img width="465" alt="Screenshot 2024-01-04 at 2 02 09 PM" src="https://github.com/lucasderraugh/SwiftUIFetchRequestBug/assets/714282/0a0f402c-2977-4641-9c57-90531fc160af"> | <img width="470" alt="Screenshot 2024-01-04 at 2 02 37 PM" src="https://github.com/lucasderraugh/SwiftUIFetchRequestBug/assets/714282/91663e4f-646e-40d4-8727-e7e97a3a1985"> |
