/// The kind of operation to run against the extracted/typed text.
/// Lives in domain because it's a business concept (what the app *does*),
/// not a UI concept (how it's presented) -- the presentation layer maps
/// this to chips/buttons, but the enum itself belongs here.
enum PromptMode { summarize, actionItems, ask }
