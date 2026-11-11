import SwiftUI

/// Base URL, model name, API key and context size fields for the custom AI provider.
struct CustomProviderFields: View {
    @Bindable var settings: AIModelSettings

    private enum Field { case baseURL, model, apiKey }
    @FocusState private var focus: Field?

    var body: some View {
        Group {
        LabeledContent("Base URL") {
            TextField("Base URL", text: $settings.baseURL, prompt: Text(verbatim: "https://api.openai.com/v1"))
                .labelsHidden()
                .multilineTextAlignment(.trailing)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                #endif
                .focused($focus, equals: .baseURL)
        }
        if settings.isBaseURLInvalid {
            Text("Use https:// (http is only allowed for localhost, 127.0.0.1 and ::1).")
                .font(.caption)
                .foregroundStyle(.red)
        }

        LabeledContent("Model name") {
            TextField("Model name", text: $settings.modelName, prompt: Text(verbatim: "gpt-4o-mini"))
                .labelsHidden()
                .multilineTextAlignment(.trailing)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .focused($focus, equals: .model)
        }
        if settings.isModelNameMissing {
            Text("Enter a model name")
                .font(.caption)
                .foregroundStyle(.red)
        }

        LabeledContent("API key (optional)") {
            SecureField("API key (optional)", text: $settings.apiKey)
                .labelsHidden()
                .multilineTextAlignment(.trailing)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .focused($focus, equals: .apiKey)
        }
        if settings.keychainFailed {
            Text("Couldn't save the API key to the Keychain.")
                .font(.caption)
                .foregroundStyle(.red)
        }

        Picker("Context size", selection: $settings.contextSize) {
            ForEach(CustomModelSettings.contextSizeOptions, id: \.self) { size in
                Text("\(size / 1024)K tokens").tag(size)
            }
        }
        Text("Match your model's context window. If answers ignore the sources, choose a smaller value.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .onSubmit(settings.commit)
        .onChange(of: focus) { settings.commit() }
        .onChange(of: settings.contextSize) { settings.commit() }
    }
}
