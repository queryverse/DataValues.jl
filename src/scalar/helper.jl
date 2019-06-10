macro lift(f_sign, ret_type)

    func_name = f_sign.args[1].args[1]
    arg_type_name = f_sign.args[1].args[2].args[2]
    type_constraint = f_sign.args[2]

    quote
        function $(esc(func_name))(x::DataValue{$(esc(arg_type_name))}) where {$(esc(type_constraint))}
            return isna(x) ? DataValue{$(esc(ret_type))}() : DataValue{$(esc(ret_type))}($(esc(func_name))(unsafe_get(x)))
        end

        $(esc(func_name))(::DataValue{Union{}}) = NA
    end
end
