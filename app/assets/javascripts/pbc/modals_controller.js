//= require can.jquery-all
//= require pbc/response
//= require pbc/system
//= require pbc/person

can.Control("CMS.Controllers.PBCModals", {
    defaults : {}
}, {
    ".add-document click" : function(el, ev) {
        this.selected_system_id = el.closest("[data-system-id]").data("system-id");
    }

    , ".documents-list li click" : function(el, ev) {
        var that = this
        , sys_id = this.selected_system_id;
        new CMS.Models.ObjectDocument({
            document_id : el.data("id")
            , system_id : this.selected_system_id
            , role : 'General Doc'
        })
        .save();
    } 

    , '.pbc-add-response > a modal:success' : function(el, e, data) {
      var $this = $(el)
        , resp = new CMS.Models.Response()
        ;
      resp.attr({
        request_id: $(e.target).closest("[data-filter-id]").data("filter-id")
        , system_id: data.id
      });
      resp.save();
    }

    , 'a.system-edit modal:success' : function(el, e, data) {
      var $this = $(el)
        , response_id = $this.closest('li[data-id]').data('id')
        , response = CMS.Models.Response.findInCacheById(response_id)
        , system_id = response.attr('system_id')
        , system = CMS.Models.System.findInCacheById(response.attr('system_id'))
        ;
      system.attr(data);
    }

    , '.pbc-control > a modal:select' : function(el, e, control_data) {
      var $this = $(el)
        , request_id = $this.closest('li[data-filter-id]').data('filter-id')
        ;

      $.post(
        '/requests/' + request_id,
        { _method: 'put'
        , 'request[control_id]': control_data.id
        }, function(data) {
          // FIXME: Brad, fix this if/when Requests are live-bound
          $this.closest('.pbc-control').find('.item').text(control_data.slug);

          // FIXME: Brad - we may want to eventually avoid refreshing the page here.
          window.location.assign(window.location.href.replace(/#.*/, ''));
      });
    }

    , '.pbc-control-select > a modal:select' : function(el, e, control_data) {
      var $this = $(el)

      $this.closest('.pbc-control-select').find('.item').text(control_data.slug);
      $("#request_control_id").val(control_data.id)
    }
});