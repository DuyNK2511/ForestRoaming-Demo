# ForestRoaming-Demo
This project is a demo for my solution about synchronous messaging between native iOS and WebGL application.
This app is about a walk in the forest using data from native iOS:
- Tap: to go straight ahead
- Rotate the phone in different directions: to change the camera angle

Laptop browser version of this app: https://duynk2511.github.io/ForestRoamingWebGL/

# Core
Create a synchronous messaging layer at application layer to achieve no message loss, in-order messages and duplicate-free based on Selective Repeat Protocol.

An interactive visualization of this protocol: https://media.pearsoncmg.com/ph/esm/ecs_kurose_compnetwork_8/cw/content/interactiveanimations/selective-repeat-protocol/index.html (From Computer Networking of Jim Kurose Homepage)

# Slides
https://www.canva.com/design/DAGqJSCOzQQ/NbjB94pb6jnD9Y2nvZ9PjQ/edit

# Evaluation
To evaluate the effectiveness of the synchronous messaging system between native iOS and WebGL, I conducted a series of tests focusing on accuracy, ordering, and reliability under different message frequencies.

Accuracy and Ordering

The messaging protocol is designed based on the Selective Repeat mechanism, which ensures that all messages are delivered exactly once, in correct order, and without loss.

I ran experiments at three different message frequencies ,which represent various application scenarios, for approximately 10000 messages:

| Frequency | Scenario                           | Reordering Errors | Message Loss |
|-----------|------------------------------------|-------------------|---------------|
| 1 Hz      | Low-frequency interaction          | 0                 | 0             |
| 30 Hz     | Medium-frequency (e.g. frame sync) | 0                 | 0             |
| 60 Hz     | High-frequency (real-time control) | 0                 | 0             |

The number of message loss is counted by a variable only increase when receive next in-order message. The number of wrong order message is counted by keep tracking real order of a message and whenever the message taken out from the queue is different, increase this number by 1.

These results show that the messaging layer handles synchronization reliably and consistently across all test conditions.
