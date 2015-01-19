'use strict'


angular.module('xin_listResource', ['ngRoute', 'angularUtils.directives.dirPagination', 'xin_session'])
  .config (paginationTemplateProvider) ->
    paginationTemplateProvider.setPath('scripts/xin/list_resource_drt/dirPagination.tpl.html')
  .controller 'ListResourceCtrl', ($scope, $routeParams, session, resourceBackend) ->
    resourceName = resourceBackend.route
    session.getIsAdminPromise().then (isAdmin) ->
      $scope.isAdmin = isAdmin
    $scope[resourceName] = []
    $scope.totalItems = 0
    $scope.itemsPerPage = 25

    $scope.loading = true
    currentPage = parseInt($routeParams.page) or 1
    $scope.pagination =
      current: currentPage
    $scope.maxResults = $routeParams.maxResults or 20
    $scope.pageChanged = (newPage) ->
      $scope.loading = true
      params =
        page: newPage
        max_results: $scope.maxResults
      resourceBackend.getList(params).then (items) ->
        $scope[resourceName] = items.plain()
        $scope.currentPage = items._meta.page
        $scope.totalItems = items._meta.total
        $scope.maxResults = items._meta.max_results
        $scope.loading = false
    $scope.pageChanged(currentPage)
