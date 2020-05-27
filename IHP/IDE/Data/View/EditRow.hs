module IHP.IDE.Data.View.EditRow where

import IHP.ViewPrelude
import IHP.IDE.SchemaDesigner.Types
import IHP.IDE.ToolServer.Types
import IHP.IDE.ToolServer.Layout
import IHP.View.Modal
import IHP.IDE.SchemaDesigner.View.Layout
import IHP.IDE.ToolServer.Types
import IHP.IDE.Data.View.ShowDatabase
import IHP.IDE.Data.View.Layout
import Data.Maybe

data EditRowView = EditRowView
    { tableNames :: [Text]
    , tableName :: Text
    , rows :: [[DynamicField]]
    , tableCols :: [ColumnDefinition]
    , rowValues :: [DynamicField]
    , id :: Text
    }

instance View EditRowView ViewContext where
    html EditRowView { .. } = [hsx|
        <div class="container pt-5">
            <div class="row no-gutters bg-white">
                {renderTableSelector tableNames tableName}
                <div class="col">
                    {renderRows}
                </div>
            </div>
            {customQuery}
        </div>
        {Just modal}
    |]
        where
            renderRows = [hsx|
                <table class="table table-sm table-hover table-striped data-rows-table">
                    {tableHead}
                    {tableBody}
                </table>
            |]

            tableHead = [hsx|<thead><tr>{forEach columnNames renderColumnHead}</tr></thead>|]
            renderColumnHead name = [hsx|<th>{name}</th>|]

            tableBody = [hsx|<tbody>{forEach rows renderRow}</tbody>|]
            renderRow fields = [hsx|<tr>{forEach fields renderField}
                <td>
                    <form method="POST" action={DeleteEntryAction id tableName}>
                        <button type="submit">Delete</button>
                        <input type="hidden" name="_method" value="DELETE"/>
                    </form>
                </td>
            </tr>|]
            renderField DynamicField { .. } = [hsx|<td><span data-fieldname={fieldName}>{fieldValue}</span></td>|]

            columnNames = map (get #fieldName) (fromMaybe [] (head rows))

            modalContent = [hsx|
                <form method="POST" action={UpdateRowAction}>
                    <input type="hidden" name="tableName" value={tableName}/>
                    {forEach (zip tableCols rowValues) renderFormField}
                    <div class="text-right">
                        <button type="submit" class="btn btn-primary">Edit Row</button>
                    </div>
                </form>
            |]
            modalFooter = mempty 
            modalCloseUrl = pathTo ShowTableRowsAction { tableName }
            modalTitle = "Edit Row"
            modal = Modal { modalContent, modalFooter, modalCloseUrl, modalTitle }

            renderFormField col = [hsx|
                    <div class="form-group">
                        <label class="row-form">{get #columnName (fst col)}</label>
                        <span style="float:right;">
                            <a class="text-muted row-form">{get #columnType (fst col)}</a>
                        </span>
                        
                        <input
                            type="text"
                            name={get #columnName (fst col)}
                            class="form-control"
                            value={"'" <> (fromMaybe "" (get #fieldValue (snd col))) <> "'"}
                            />
                    </div>|]