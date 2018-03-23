# BigWigs_ThaddiusArrows
BigWigs Strategy Module for Thaddius in Naxxramas.

BigWigs_ThaddiusArrows is a separate module for BigWigs because it involves
strategy and tells the player directly what to do, instead of simply providing
information on what happens in the encounter.

BW_TA assumes that your raid is bunched up at the start of phase 2. After the
first Polarity Shift it will tell you everyone in the raid to rotate 90 degrees.
If your debuff changed, you move in one direction, and if it didn't, you move in another.

The only difference is the starting direction based on debuff; Right for Positive 
on the first charge and left for Negative on the first charge, and then right if you 
did not change and left if you did.

Currently it can announce the direction to move in 3 ways:
 * Displaying huge arrows on-screen.
 * A BigWigs text message with directional text arrows like "<---", etc.
 * A female voice that says "Go right", etc.

![Go Right!](http://cdn-wow.mmoui.com/preview/pvw3658.jpg)

## Authors
Original coding, arrows and sounds was done by Kebinusan.

Developed further by Rabbit.

Updated here for use with 1.12.1 on Light's Hope project realms by Towneh.
