# Theme System (White-labeling)

*This document is a stub. It will be fleshed out as the global theme system is implemented.*

**Concept:** 
GymKit does not use hardcoded colors or styles in feature code. A global `ThemeData` is built dynamically at startup using a `ThemeExtension<AppTokens>`. This allows the entire app's look and feel to adapt to the specific tenant's branding configuration.
