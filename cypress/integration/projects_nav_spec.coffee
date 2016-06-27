describe "Projects Nav", ->
  beforeEach ->

    cy
      .visit("/")
      .window().then (win) ->
        {@ipc, @App} = win

        @agents = cy.agents()

        @agents.spy(@App, "ipc")

        @ipc.handle("get:options", null, {})
      .fixture("user").then (@user) ->
        @ipc.handle("get:current:user", null, @user)
      .fixture("projects").then (@projects) ->
        @ipc.handle("get:project:paths", null, @projects)

  context "project nav", ->
    beforeEach ->
      cy
        .fixture("browsers").then (browsers) ->
          @config = {
            clientUrl: "http://localhost:2020",
            clientUrlDisplay: "http://localhost:2020"
          }
          @config.browsers = browsers
        .get(".projects-list a")
          .contains("My-Fake-Project").as("firstProject").click().then ->
            @ipc.handle("open:project", null, @config)


    it "displays projects nav", ->
      cy
        .get(".empty").should("not.be.visible")
        .get(".navbar-default")

    describe "default page", ->
      it "displays 'tests' nav as active", ->
        cy
          .get(".navbar-default").contains("a", "Tests")
            .should("have.class", "active")

      it "displays 'tests' page", ->
        cy
          .contains("Integration")

    describe "config page", ->
      beforeEach ->
        cy
          .get(".navbar-default")
            .contains("a", "Config").as("configNav").click()

      it.skip "highlights config on click", ->
        cy
          .get("@configNav")
            .should("have.class", "active")

      it "navigates to config url", ->
        cy
          .location().its("hash").should("include", "config")

      it "displays config page", ->
        cy
          .contains("h4", "Config")

  context "browsers dropdown", ->
    beforeEach ->
      @config = {
        clientUrl: "http://localhost:2020",
        clientUrlDisplay: "http://localhost:2020"
      }

    describe "browsers available", ->
      beforeEach ->
        cy
          .fixture("browsers").then (@browsers) ->
            @config.browsers = @browsers
          .get(".projects-list a")
            .contains("My-Fake-Project").as("firstProject").click().then ->
              @ipc.handle("open:project", null, @config)

      it "lists browsers", ->
        cy
          .get(".browsers-list").parent()
          .find(".dropdown-menu").first().find("li").should("have.length", 2)
          .should ($li) ->
            expect($li.first()).to.contain("Chromium")
            expect($li.last()).to.contain("Canary")

      it "displays default browser name in chosen", ->
        cy
          .get(".browsers-list>a").first()
            .should("contain", "Chrome")

      it "displays default browser icon in chosen", ->
        cy
          .get(".browsers-list>a").first()
            .find(".fa-chrome")

      context "switch browser", ->
        beforeEach ->
          cy
            .get(".browsers-list>a").first().click()
            .get(".browsers-list").find(".dropdown-menu")
              .contains("Chromium").click()

        it "switches text in button on switching browser", ->
          cy
            .get(".browsers-list>a").first().contains("Chromium")

        # it "sends the 'launch:browser' event immediately", ->
        #   cy.wrap(@App.ipc).should("be.calledWith", "launch:browser", {
        #     browser: "chromium"
        #     url: undefined
        #   })

        it "swaps the chosen browser into the dropdown", ->
          cy
            .get(".browsers-list").find(".dropdown-menu")
            .find("li").should("have.length", 2)
            .should ($li) ->
              expect($li.first()).to.contain("Chrome")
              expect($li.last()).to.contain("Canary")

      # context.skip "relaunch browser", ->
      #   beforeEach ->
      #     cy
      #       .get("@firstProject").click()

      #   it "attaches 'on:launch:browser' after project opens", ->
      #     cy.wrap(@App.ipc).should("be.calledWith", "on:launch:browser")

      #   it "relaunchers browser when 'on:launch:browser' fires", ->
      #     @ipc.handle("on:launch:browser", null, {
      #       browser: "chromium"
      #       url: "http://localhost:2020/__/#tests/foo_spec.js"
      #     })

      #     cy
      #       .wrap(@App.ipc).should("be.calledWith", "launch:browser", {
      #         browser: "chromium"
      #         url: "http://localhost:2020/__/#tests/foo_spec.js"
      #       })
      #       .get(".browsers-list>a").first().contains("Chromium")

    describe "only one browser available", ->
      beforeEach ->
        @config = {
          clientUrl: "http://localhost:2020",
          clientUrlDisplay: "http://localhost:2020"
        }

        @oneBrowser = [{
          "name": "chrome",
          "version": "50.0.2661.86",
          "path": "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
          "majorVersion": "50"
        }]

        cy
          .fixture("browsers").then ->
            @config.browsers = @oneBrowser
          .get(".projects-list a")
            .contains("My-Fake-Project").as("firstProject").click().then ->
              @ipc.handle("open:project", null, @config)

      context "displays no dropdown btn", ->
        it "displays the first browser and 2 others in the dropdown", ->
          cy
            .get(".browsers-list")
              .find(".dropdown-toggle").should("not.be.visible")

    describe "no browsers available", ->
      beforeEach ->
        cy
          .get(".projects-list a")
            .contains("My-Fake-Project").as("firstProject").click().then ->
              @config.browsers = []
              @ipc.handle("open:project", null, @config)

      it "does not list browsers", ->
        cy.get(".browsers-list").should("not.exist")

      it "displays browser error", ->
        cy.contains("We couldn't find any Chrome browsers")

      it "displays download browser button", ->
        cy.contains("Download Chrome")

      describe.skip "download browser", ->
        it "triggers external:open on click", ->
          cy
            .contains(".btn", "Download Chrome").click().then ->
              expect(@App.ipc).to.be.calledWith("external:open", "https://www.google.com/chrome/browser/")

  context "switch project", ->
    beforeEach ->
      cy
        .fixture("browsers").then (browsers) ->
          @config = {
            clientUrl: "http://localhost:2020",
            clientUrlDisplay: "http://localhost:2020"
          }
          @config.browsers = browsers
        .get(".projects-list a")
          .contains("My-Fake-Project").as("firstProject").click().then ->
            @ipc.handle("open:project", null, @config)

    it "closes project", ->
      cy.contains("Back to Projects").click().then ->
        expect(@App.ipc).to.be.calledWith("close:project")

    describe "click on diff project", ->
      beforeEach ->
        cy
          .contains("Back to Projects").click()
          .get(".projects-list a")
            .contains("project1").click().then ->
              @ipc.handle("open:project", null, @config)

      it "displays projects nav", ->
        cy
          .get(".empty").should("not.be.visible")
          .get(".navbar-default")
