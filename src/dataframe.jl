function dataframe(resp::Requests.Response)

    buffer = PipeBuffer() # open a buffer in which to dump data
    df     = DataFrame()  # init empty DataFrame

    datesym = nothing
    try
        # Write the data to the buffer
        write(buffer, Requests.text(resp))

        # Use DataFrame's readtable to read the data directly from buffer
        df = readtable(buffer)
        
        # Convert dates to Dates object
        if :Date in names(df)
            datesym = :Date
            df[datesym] = Date[Date(d) for d in df[datesym]]
        elseif :date in names(df)
            datesym = :date
            df[datesym] = Date[Date(d) for d in df[datesym]]
        end

    finally
        close(buffer)   
    end

    # force oldest date to first row
    if datesym == nothing || issorted(df[datesym]) 
        return df
    else
        return sort!(df, cols=[datesym])
    end
end
