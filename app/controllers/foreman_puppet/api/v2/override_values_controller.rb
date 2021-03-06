module ForemanPuppet
  module Api
    module V2
      class OverrideValuesController < LookupsCommonController
        include Foreman::Controller::Parameters::LookupValue

        resource_description do
          api_version '2'
          api_base_url '/foreman_puppet/api'
        end

        before_action :find_override_values
        before_action :find_override_value, only: %i[show update destroy]
        # override return_if_smart_mismatch in LookupKeysCommonController to add :create
        before_action :return_if_smart_mismatch, only: %i[create show update destroy]
        before_action :return_if_override_mismatch, only: %i[show update destroy]

        before_action :cast_value, only: %i[create update]

        api :GET, '/smart_class_parameters/:smart_class_parameter_id/override_values', N_('List of override values for a specific smart class parameter')
        param :smart_class_parameter_id, :identifier, required: false
        param :show_hidden, :bool, desc: N_('Display hidden values')
        param_group :pagination, ::Api::V2::BaseController

        def index
        end

        api :GET, '/smart_class_parameters/:smart_class_parameter_id/override_values/:id', N_('Show an override value for a specific smart class parameter')
        param :smart_class_parameter_id, :identifier, required: false
        param :id, :identifier, required: true
        param :show_hidden, :bool, desc: N_('Display hidden values')

        def show
        end

        def_param_group :override_value do
          param :override_value, Hash, required: true, action_aware: true do
            param :match, String, required: true, desc: N_('Override match')
            param :value, :any_type, of: LookupKey::KEY_TYPES, required: false, desc: N_('Override value, required if omit is false')
            param :omit, :bool, required: false, desc: N_('Foreman will not send this parameter in classification output')
          end
        end

        api :POST, '/smart_class_parameters/:smart_class_parameter_id/override_values', N_('Create an override value for a specific smart class parameter')
        param :smart_class_parameter_id, :identifier, required: false
        param_group :override_value, as: :create

        def create
          @override_value = @smart_class_parameter.lookup_values.create!(lookup_value_params)
          @smart_class_parameter.update(override: true)
          process_response @override_value
        end

        api :PUT, '/smart_class_parameters/:smart_class_parameter_id/override_values/:id', N_('Update an override value for a specific smart class parameter')
        param :smart_class_parameter_id, :identifier, required: false
        param_group :override_value

        def update
          @override_value.update!(lookup_value_params)
          render 'foreman_puppet/api/v2/override_values/show'
        end

        api :DELETE, '/smart_class_parameters/:smart_class_parameter_id/override_values/:id', N_('Delete an override value for a specific smart class parameter')
        param :smart_class_parameter_id, :identifier, required: false
        param :id, :identifier, required: true

        def destroy
          @override_value.destroy
          render 'foreman_puppet/api/v2/override_values/show'
        end

        private

        def find_override_values
          return unless @smart_class_parameter

          @override_values = @smart_class_parameter.lookup_values.paginate(paginate_options)
          @total = @override_values.count
        end

        def find_override_value
          @override_value = LookupValue.find_by(id: params[:id])
          @override_value ||= @smart_class_parameter.lookup_values.friendly.find(params[:id]) if @smart_class_parameter
        end

        def return_if_override_mismatch
          return unless (@override_values && @override_value && !@override_values.find_by(id: @override_value.id)) || (@override_values && !@override_value) || !@override_values

          not_found "Override value not found by id '#{params[:id]}'"
        end

        # overwrite Api::BaseController
        def resource_class
          LookupValue
        end
      end
    end
  end
end
