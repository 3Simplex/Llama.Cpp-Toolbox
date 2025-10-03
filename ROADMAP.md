# LlamaCpp-Toolbox Roadmap

Welcome to the LlamaCpp-Toolbox Roadmap! This document provides a high-level overview of our strategic vision, ongoing development efforts, and future goals.


## Vision

To be the most intuitive, powerful, and adaptable PowerShell-based toolbox for interacting with and managing `llama.cpp` and local LLMs, empowering users with seamless control over their AI models and configurations.

## Near-Term Goals (Next 1-3 Months)

*   **Community-Driven Feature Development:** Foster a robust community contribution model to continuously enhance the Toolbox.
*   **Flexible Repository/Branch Selection:** Introduce the ability for users to specify custom `llama.cpp` repository URLs and branches, enabling testing with forks, custom builds, or experimental branches. 
*   **Enhanced Model Acquisition UI:** Integrate `curl` functionality for model downloads, providing more flexible and robust options for acquiring models. This also includes accounting for new LLM distribution systems beyond Git (e.g., Huggingface's new system). 
*   **Standardized `llama.cpp` Command Handling:** Refactor how the Toolbox constructs and manages `llama.cpp` commands to align more closely with `llama.cpp`'s native command-line interface, making it easier for users to copy/paste and adapt existing commands. 
*   **Improved `llama.cpp` Documentation Access:** Implement features to make `llama.cpp` documentation more accessible and user-friendly directly within the Toolbox. 

## Mid-Term Goals (Next 3-6 Months)

*   **Advanced Configuration Management UI:**
    *   **Search/Filter Functionality:** Add search and filtering capabilities for items like branch names and other configuration parameters within the UI.
    *   **Dynamic Line Management:** Implement UI features to allow users to add new lines or clone existing configuration entries within `config.json` directly from the menu. 
    *   **Record Deletion:** Provide the ability to delete specific records from the `config.json` file through the UI menu.
*   **UI Feedback Improvements:** Display a "Committed" button state when text input (e.g., in chat or command entry) is finished writing, providing clear visual feedback to the user.

## Long-Term Goals (6+ Months / Future Vision)

*   **Deepened `llama.cpp` Integration & Ease of Use:** Continuously enhance the core `llama.cpp` experience, focusing on making complex operations simpler and more accessible. This includes:
    *   Streamlining `llama.cpp` build and configuration processes within the Toolbox.
    *   Developing advanced features to manage and interact with `llama.cpp` models more intuitively.
    *   Improving existing API integrations to provide a seamless and powerful user experience with `llama.cpp`-backed LLMs.
*   **Advanced Automation for `llama.cpp` Workflows:** Expand capabilities for automated model management, fine-tuning, and deployment workflows specifically tailored for `llama.cpp` models. This might involve:
    *   Developing specialized workflow orchestration tools for complex, chained `llama.cpp` interactions.
    *   Implementing automated performance testing and benchmarking routines for `llama.cpp` models.
    *   Creating customizable prompt templating and management systems optimized for `llama.cpp`'s capabilities.

**Note:** This roadmap is a living document and is subject to change based on project priorities, community feedback, and the evolving landscape of local LLMs. Your input is invaluable!