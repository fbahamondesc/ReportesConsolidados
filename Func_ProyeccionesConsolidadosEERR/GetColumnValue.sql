CREATE FUNCTION dbo.GetColumnValue(
	@String varchar(8000),
	@Delimiter char(1),
	@Column int = 1
)
returns varchar(8000)
as     
begin

declare @idx int     
declare @slice varchar(8000)     

select @idx = 1     
    if len(@String)<1 or @String is null  return null

declare @ColCnt int
    set @ColCnt = 1

while (@idx != 0)
begin     
    set @idx = charindex(@Delimiter,@String)     
    if @idx!=0 begin
        if (@ColCnt = @Column) return left(@String,@idx - 1)        

        set @ColCnt = @ColCnt + 1

    end

    set @String = right(@String,len(@String) - @idx)     
    if len(@String) = 0 break
end 
return @String  
end