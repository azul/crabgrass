# Inspired by:
#   Redmine - project management software
#   Copyright (C) 2006-2008  Jean-Philippe Lang
#   License: GPL v2 or later

module Crabgrass #:nodoc:
  module Hook #:nodoc:
    @@listener_classes = []
    @@listeners = nil
    @@hook_listeners = {}

    def self.listener_classes
      @@listener_classes
    end

    class << self
      # Adds a listener class.
      # Automatically called when a class inherits from Crabgrass::Hook::Listener.
      def add_listener(klass)
        raise "Hooks must include Singleton module." unless klass.included_modules.include?(Singleton)
        @@listener_classes << klass
        clear_listeners_instances
      end

      # Returns all the listerners instances.
      def listeners
        @@listeners ||= @@listener_classes.collect {|listener| listener.instance}
      end

      # Returns the listeners instances for the given hook.
      def hook_listeners(hook)
        @@hook_listeners[hook] ||= listeners.select {|listener| listener.respond_to?(hook)}
      end

      # Clears all the listeners.
      def clear_listeners
        @@listener_classes = []
        clear_listeners_instances
      end

      # Clears all the listeners instances.
      def clear_listeners_instances
        @@listeners = nil
        @@hook_listeners = {}
      end

      # Calls a hook.
      # Returns the listeners response.
      def call_hook(hook, context={})
        listeners = hook_listeners(hook)
        if listeners.size > 1
          raise 'too many listeners for call_hook!'
        elsif listeners.size < 1 
          return
        end
        listeners[0].delegate_to(context[:delegate_to]) if context[:delegate_to]
        listeners[0].send(hook, context)
      end

      def call_hooks(hook, context={}, options={})
        response = []
        hook_listeners(hook).each do |listener|
          listener.delegate_to(context[:delegate_to]) if context[:delegate_to]
          response << listener.send(hook, context)
        end
        unless options[:format] == :array
          response.join("\n")
        end
      end
    end

    # Base class for hook listeners.
    class Listener
      include Singleton

      def delegate_to(object)
        @delegator = object
      end
      def method_missing(method, *args)
        if @delegator
          @delegator.send(method, *args)
        else
          super(method, *args)
        end
      end

      # Registers the listener
      def self.inherited(child)
        Crabgrass::Hook.add_listener(child)
        super
      end
    end

    class ViewListener < Listener
    end

    # Helper module included in ApplicationHelper so that hooks can be called
    # in views like this:
    #   <%= call_hook(:some_hook) %>
    #   <%= call_hook(:another_hook, :foo => 'bar' %>
    #
    # Current project is automatically added to the call context.
    module Helper
      def hook_defaults
        {:page => @page, :user => @user, :group => @group, :delegate_to => self, :session => session, :params => params}
      end
      def call_hook(hook, context={})
        Crabgrass::Hook.call_hook(hook, hook_defaults.merge(context))
      end
      # use call_hooks to call multiple hooks with the same name
      # use the following to return an array of return values from the hooks:
      # options[:format] = :array
      # otherwise returns a joined string of the responses
      def call_hooks(hook, context={}, options={})
        Crabgrass::Hook.call_hooks(hook, hook_defaults.merge(context), options)
      end
      def hook_exists(hook)
        return true if !Crabgrass::Hook.hook_listeners(hook).empty?
      end
    end
  end
end

# this is done in an initializer instead:
#ApplicationHelper.send(:include, Crabgrass::Hook::Helper)
