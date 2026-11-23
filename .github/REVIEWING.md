# Request a PR review

Comment on a pull request in this fork with one of these commands. Put the
command first, then describe what you would like the reviewer to check.

```text
/claude-sonnet-5.5-high Review this change and its tests.
/copilot-claude-sonnet-5.5-high Check the behavior at the boundary.
/opencode-kimi-k3-default Review this change.
```

Claude accepts a family alias or a version, such as `sonnet` or `sonnet-5.5`.
Copilot takes the full Copilot CLI model ID, including the family for Claude
models. OpenCode takes the model name from its Go provider. The final field
sets the effort. Use `default` to leave effort to the CLI, or choose a level
supported by the selected model and your subscription.

Anyone with write access can ask a follow-up in the conversation, in an inline
thread, or in the body of a submitted review. An inline question gets a reply
in the same thread. Other requests get a review with a summary and any
line-specific findings. To request an OpenCode review without a comment,
apply a label such as `review:opencode-kimi-k3-default`.
