USE WSysComasurCloundDB;
GO
IF EXISTS (SELECT * FROM sysobjects WHERE NAME ='SP_Load_Menu')
BEGIN
	DROP PROCEDURE dbo.SP_Load_Menu
	PRINT 'EL PROCEDIMIENTO "SP_Load_Menu" SE BORRO CORRECTAMENTE'
END
GO
CREATE PROCEDURE dbo.SP_Load_Menu
@UserID NVARCHAR(128)
AS
	DELETE MenuTemp
	DECLARE @MenuID INT, @DisplayName NVARCHAR(50),	@ParentMenuID INT, @OrderNumber INT,@MenuURL NVARCHAR(100), @MenuIcon NVARCHAR(25)
	DECLARE MENU_CURSOR CURSOR
	FOR SELECT a.MenuID,a.DisplayName,a.ParentMenuID, a.OrderNumber, a.MenuURL,a.MenuIcon  
		FROM Menu a	
		INNER JOIN Permission b ON b.MenuID = a.MenuID
		INNER JOIN AspNetRoles c ON c.Id = b.RoleID		
		INNER JOIN AspNetUserRoles d ON d.RoleId = c.Id and d.UserId= @UserID
		WHERE a.ParentMenuID=0
		
		UNION ALL
		SELECT a.MenuID,a.DisplayName,a.ParentMenuID, a.OrderNumber, a.MenuURL,a.MenuIcon
		FROM Menu a	
		INNER JOIN CustomPermission b ON b.MenuID = a.MenuID
		INNER JOIN AspNetUsers c ON c.Id =b.UserID AND c.Id =@UserID			
		WHERE a.ParentMenuID=0

	OPEN MENU_CURSOR
	FETCH NEXT FROM MENU_CURSOR INTO @MenuID, @DisplayName,	@ParentMenuID, @OrderNumber,@MenuURL, @MenuIcon
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO MenuTemp SELECT @MenuID, @DisplayName,	@ParentMenuID, @OrderNumber,@MenuURL, @MenuIcon
		INSERT INTO MenuTemp SELECT a.MenuID,a.DisplayName,a.ParentMenuID, a.OrderNumber, a.MenuURL,a.MenuIcon FROM Menu a		
		INNER JOIN Permission b ON b.MenuID = a.MenuID
		INNER JOIN AspNetRoles c ON c.Id = b.RoleID		
		INNER JOIN AspNetUserRoles d ON d.RoleId = c.Id and d.UserId=@UserID
		WHERE a.ParentMenuID>0 AND a.ParentMenuID=@MenuID

			UNION ALL
			SELECT a.MenuID,a.DisplayName,a.ParentMenuID, a.OrderNumber, a.MenuURL,a.MenuIcon FROM Menu a	
			INNER JOIN CustomPermission b ON b.MenuID = a.MenuID
			INNER JOIN AspNetUsers c ON c.Id =b.UserID AND c.Id =@UserID
			WHERE a.ParentMenuID>0 AND a.ParentMenuID=@MenuID
			ORDER BY a.OrderNumber
		FETCH NEXT FROM MENU_CURSOR INTO @MenuID, @DisplayName,	@ParentMenuID, @OrderNumber,@MenuURL, @MenuIcon
	END
	SELECT a.MenuID,a.DisplayName,a.ParentMenuID, a.OrderNumber, a.MenuURL,a.MenuIcon FROM MenuTemp a	
	CLOSE MENU_CURSOR
	DEALLOCATE MENU_CURSOR
GO
GO


IF EXISTS(select * from sysobjects where name = 'SP_GetMenu')
BEGIN
	DROP PROCEDURE dbo.SP_GetMenu
	PRINT 'El procedimiento "SP_GetMenu" Fue eliminado correctamente'
END
GO
CREATE PROCEDURE dbo.SP_GetMenu
@UserID NVARCHAR(128),@RoleID NVARCHAR(128)
AS	
	IF @RoleID IS NOT NULL
	BEGIN
		WITH QPermission AS (
			SELECT a.MenuID, a.DisplayName, a.ParentMenuID,b.PermissionID FROM Menu a
			LEFT JOIN Permission b ON b.MenuID = a.MenuID and b.RoleID=@RoleID)
			SELECT q.MenuID, q.DisplayName,q.ParentMenuID,PermissionType=0, Permission= CASE WHEN(ISNULL(q.PermissionID,0))=0 THEN CONVERT(BIT,0) ELSE CONVERT(BIT,1) END FROM QPermission q
	END	
	ELSE IF @UserID IS NOT NULL
	BEGIN
		WITH QPermission AS (
			SELECT a.MenuID, a.DisplayName, a.ParentMenuID,b.CustomPermissionID FROM Menu a
			LEFT JOIN CustomPermission b ON b.MenuID = a.MenuID and b.UserID=@UserID)
			SELECT q.MenuID, q.DisplayName,q.ParentMenuID,PermissionType=1, Permission= CASE WHEN(ISNULL(q.CustomPermissionID,0))=0 THEN CONVERT(BIT,0) ELSE CONVERT(BIT,1) END FROM QPermission q
	END	
GO
GO

