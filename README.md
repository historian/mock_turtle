# Mock Turtle

From mockup to production in *zero* steps.

    <html>
      <head>
        <title data-content="page_title">Page Title</title>
        <script type="text/ruby">
          concat stylesheet_link_tag(:all)
          concat javascript_include_tag(:defaults)
          concat csrf_meta_tag
        </script>
      </head>
      <body>

        <ul id="menu">
          <li data-repeat="MenuItem.all" data-as="item">
            <a data-attr-href="item.url" data-content="item.name">Home</a>
            <a data-remove>Products</a>
            <a data-remove>Contact</a>
          </li>
        </ul>

        <div id="products" data-view="products/index">

          <div data-repeat="Product.public.all" data-as="product">
            <h2 data-content="product.name">Tea</h2>
            <p class="meta">
              <a data-attr-href="product_path(product)">More info...</a>
            </p>
          </div>

          <div data-remove>
            <h2>Cookies</h2>
            <p class="meta">
              <a>More info...</a>
            </p>
          </div>

        </div>

      </body>
    </html>