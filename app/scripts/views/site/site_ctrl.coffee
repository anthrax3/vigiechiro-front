'use strict'


angular.module('siteViews', ['ngRoute', 'textAngular', 'xin_backend', 'protocole_map'])
  .directive 'listSitesDirective', (session, Backend) ->
    restrict: 'E'
    templateUrl: 'scripts/views/site/list_sites.html'
    scope:
      protocoleId: '@'
      protocoleAlgoSite: '@'
    link: (scope, elem, attrs) ->
      scope.loading = true
      scope.sites = []
      scope.loadSites = (lookup) ->
        Backend.all('sites').getList(lookup).then (sites) ->
          scope.sites = sites.plain()
          scope.loading = false
      attrs.$observe 'protocoleId', (protocoleId) ->
        if protocoleId
          session.getUserPromise().then (user) ->
            scope.loadSites(
              where:
                protocole: protocoleId
                observateur: user._id
              embedded: { "grille_stoc": 1 }
            )

  .controller 'ShowSiteCtrl', ($timeout, $route, $routeParams, $scope
                               session, Backend, protocolesFactory) ->
    mapProtocole = undefined
    siteResource = undefined
    mapLoaded = false
    $scope.submitted = false
    $scope.isAdmin = false
    session.getIsAdminPromise().then (isAdmin) ->
      $scope.isAdmin = isAdmin
    Backend.one('sites', $scope.site._id).get().then (site) ->
      siteResource = site
    $scope.loadMap = (mapDiv) ->
      if not mapLoaded
        mapLoaded = true
        mapProtocole = protocolesFactory($scope.site, $scope.protocoleAlgoSite, mapDiv, siteCallback)
    siteCallback =
      updateForm: ->
        $scope.siteForm.$pristine = false
        $scope.siteForm.$dirty = true
        $timeout(-> $scope.$apply())
      updateSteps: (steps) ->
        $scope.steps = steps.steps
        $scope.stepId = steps.step
        $timeout(-> $scope.$apply())
    $scope.saveSite = ->
      $scope.submitted = true
      if (not $scope.siteForm.$valid or
          not $scope.siteForm.$dirty)
        return
      payload =
        'protocole': $scope.protocoleId
        'localites': mapProtocole.saveMap()
        'commentaire': $scope.siteForm.commentaire.$modelValue
        'grille_stoc': mapProtocole.getIdGrilleStoc()
      siteResource.patch(payload).then(
        -> $scope.siteForm.$setPristine()
        (error) -> console.log("error", error)
      )

  .directive 'showSiteDirective', ($timeout) ->
    restrict: 'E'
    templateUrl: 'scripts/views/site/show_site.html'
    controller: 'ShowSiteCtrl'
    scope:
      site: '='
      title: '@'
      collapsed: '@'
      protocoleAlgoSite: '@'
    link: (scope, elem, attrs) ->
      # Wait for the collapse to be opened before load the google map
      if not attrs.collapsed?
        # Use $timeout to load google map at the end of the stack
        # to prevent display issues
        $timeout(-> scope.loadMap(elem.find('.g-maps')[0]))
      else
        $(elem).on('shown.bs.collapse', ->
          scope.numero_grille_stoc = elem.find('.numero_grille_stoc')[0]
          scope.loadMap(elem.find('.g-maps')[0])
          return
        )

  .controller 'CreateSiteCtrl', ($timeout, $route, $routeParams, $scope,
                                 session, Backend, protocolesFactory) ->
    mapProtocole = undefined
    mapLoaded = false
    $scope.submitted = false
    $scope.isAdmin = false
    session.getIsAdminPromise().then (isAdmin) ->
      $scope.isAdmin = isAdmin
    $scope.site = {}
    $scope.loadMap = (mapDiv) ->
      if not mapLoaded
        mapLoaded = true
        mapProtocole = protocolesFactory($scope.site, $scope.protocoleAlgoSite, mapDiv, siteCallback)
    siteCallback =
      updateForm: ->
        $scope.siteForm.$pristine = false
        $scope.siteForm.$dirty = true
        $timeout(-> $scope.$apply())
      updateSteps: (steps) ->
        $scope.steps = steps.steps
        $scope.stepId = steps.step
        $timeout(-> $scope.$apply())
    $scope.saveSite = ->
      $scope.submitted = true
      if (not $scope.siteForm.$valid or
          not $scope.siteForm.$dirty)
        return
      payload =
        'protocole': $scope.protocoleId
        'localites': mapProtocole.saveMap()
# TODO : use coordonnee to center the map
#        'coordonnee':
#          'type': 'Point'
#          'coordinates': [mapDump[0].lng, mapDump[0].lat]
#        'numero_grille_stoc': 
        'commentaire': $scope.siteForm.commentaire.$modelValue
        'grille_stoc': mapProtocole.getIdGrilleStoc()
      Backend.all('sites').post(payload).then(
        -> $route.reload()
        (error) -> console.log("error", error)
      )

  .directive 'createSiteDirective', ->
    restrict: 'E'
    templateUrl: 'scripts/views/site/show_site.html'
    controller: 'CreateSiteCtrl'
    scope:
      protocoleId: '@'
      protocoleAlgoSite: '@'
    link: (scope, elem, attrs) ->
      scope.collapsed = true
      scope.title = 'Nouveau site'
      attrs.$observe('protocoleId', (protocoleId) ->
        scope.protocoleId = protocoleId
      )
      $(elem).on('shown.bs.collapse', ->
        scope.numero_grille_stoc = elem.find('.numero_grille_stoc')[0]
        scope.loadMap(elem.find('.g-maps')[0])
        return
      )
      attrs.$observe('protocoleAlgoSite', (value) ->
        if value
          scope.protocoleAlgoSite = value
      )
