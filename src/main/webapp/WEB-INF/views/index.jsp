<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <html>

    <head>
        <meta charset="UTF-8">
        <meta name="description" content="">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <!-- Title -->
        <title>Chat</title>
        <!-- Favicon -->
        <link rel="apple-touch-icon" sizes="180x180" href="<c:url value='/icons/apple-touch-icon.png' />">
        <link rel="icon" type="image/png" sizes="32x32" href="<c:url value='/icons/favicon-32x32.png' />">
        <link rel="icon" type="image/png" sizes="16x16" href="<c:url value='/icons/favicon-16x16.png' />">
        <link rel="manifest" href="<c:url value='/icons/site.webmanifest' />">
        <!-- css files -->
        <%@ include file="fragments/styles.jsp" %>
    </head>

    <body>
        <!-- Preloader -->
        <div id="preloader"></div>
        <!-- header content -->
        <%@ include file="layouts/header.jsp" %>
        <!-- main content -->
            <div id="mainContent">
                <jsp:include page="pages/${view}.jsp" />
            </div>
        <!-- footer content -->
            <%@ include file="layouts/footer.jsp" %>
        <!-- scripts files -->
        <%@ include file="fragments/scripts.jsp" %>

    </body>

    </html>