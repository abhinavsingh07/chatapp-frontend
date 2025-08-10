<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <c:set var="ctx" value="${pageContext.request.contextPath}" scope="request" />
        <c:set var="userid" value="${sessionScope.userid}" scope="request" />