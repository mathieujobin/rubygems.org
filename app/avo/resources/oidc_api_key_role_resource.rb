class OIDCApiKeyRoleResource < Avo::BaseResource
  self.extra_params = [{access_policy: {}, api_key_permissions: {}}]
  self.title = :id
  self.includes = []
  self.model_class = ::OIDC::ApiKeyRole
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :provider, as: :belongs_to
  field :user, as: :belongs_to
  field :api_key_permissions, as: :nested, 
    coercer: ->(v) { OIDC::ApiKeyPermissions.new OIDC::ApiKeyPermissions::Contract.new.call(v).to_h } do

    field :valid_for, as: :text
    field :scopes, as: :tags, suggestions: ApiKey::API_SCOPES
    field :gems, as: :tags
  end
  field :name, as: :text
  field :access_policy, as: :nested,
  coercer: ->(v) { OIDC::AccessPolicy.new OIDC::AccessPolicy::Contract.new.call(v).to_h } do
    field :statements, as: :array_of, field: :nested do
      field :effect, as: :select, options: { "Allow" => "allow" }, default: "Allow"
      field :principal, as: :nested do
        field :oidc, as: :text
      end
      field :conditions, as: :array_of, field: :nested do
        field :operator, as: :select, options: %w[string_equals].index_with(&:titleize)
        field :claim, as: :text
        field :value, as: :text
      end
    end
  end
  # add fields here
end
